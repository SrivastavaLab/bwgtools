# delete everything from memory -------------------------------------------
rm(list=ls(all=TRUE))


# load data frame ---------------------------------------------------------

depth<-read.table("C:\\Users\\Nick\\Desktop\\Experimento de Chuva\\1 - Predacao\\Analises\\Input\\depth.pred.drought.txt", header=TRUE)
environ<-read.table("C:\\Users\\Nick\\Desktop\\Experimento de Chuva\\1 - Predacao\\Analises\\Input\\environ.pred.drought.txt", header=TRUE, row.names="trat")
rainfall<-read.table("C:\\Users\\Nick\\Desktop\\Experimento de Chuva\\1 - Predacao\\Analises\\Input\\precipitacao.txt", header=TRUE)


# clean up data frame -----------------------------------------------------

depth<-depth[complete.cases(depth),]


# load packages -----------------------------------------------------------

library(dplyr)
library(tidyr)
library(vegan)
library(lme4)
library(car)
library(ggplot2)
library(fitdistrplus)

# how many days at least x tanks dried out? -------------------------------

n.dry<-depth %>%
  #for each treatment, in each day
  group_by(treatment, day) %>%
  #tell me
  summarise(n.tanks = sum(depth.cm == 0), #how many tanks were dry?
            #are there any tanks that were not dry?
            not.dry = sum(sum(depth.cm ==0))==0,
            #are there at least one tank that is dry?
            one.tank = sum(sum(depth.cm == 0))==1,
            #are there at least two tanks that are dry?
            two.tanks = sum(sum(depth.cm == 0))==2,
            #are there at least three tanks that are dry?
            three.tanks = sum(sum(depth.cm == 0))==3) %>%
  #for each treatment, tell me how many days...
  group_by(treatment) %>%
  summarise(no.tank = sum(not.dry > 0), #no tank was dry?
            one.tank = sum(one.tank > 0), #at least one tank was dry?
            two.tanks = sum(two.tanks >0), #at least two tanks were dry?
            three.tanks = sum(three.tanks >0), #at least three tanks were dry?
            any.tank = 23 - sum(not.dry > 0)) %>% #there was any number of dry tanks (23 is the total number of days observed)
  mutate(trt = treatment) %>%
  separate(trt, into = c("pred", "chuva", "bloco"), sep = c(1,2))

head(n.dry)
plot(no.tank ~ as.factor(chuva), data=n.dry)
plot(one.tank ~ as.factor(chuva), data=n.dry, outline)
plot(two.tanks ~ as.factor(chuva), data=n.dry)
plot(three.tanks ~ as.factor(chuva), data=n.dry)
plot(any.tank ~ as.factor(chuva), data=n.dry)

# take the measurements independently for each cup ------------------------

hidrologia.tanque<-depth %>%
  group_by(treatment, numb.cup) %>%
  mutate(depth.total = depth.cm - lag(depth.cm),
         depth.fluct = abs(depth.cm - lag(depth.cm))) %>%
  summarise(prof.max = max(depth.cm), prof.min = min(depth.cm),
            amplitude = max(depth.cm) - min(depth.cm),
            dryness = mean(depth.cm)/max(depth.cm),
            prof.mean = mean(depth.cm), var.prof = var(depth.cm),
            sd.prof = sd(depth.cm), prof.cv = (100*(sd(depth.cm))/mean(depth.cm)),
            overflow.days = sum(depth.cm == prof.max)-1,
            deadvol.days = sum(depth.cm == prof.min),
            days.dry = sum(depth.cm == 0),
            vol.up = sum(depth.cm > lag(depth.cm), na.rm=TRUE),
            vol.down = sum(depth.cm < lag(depth.cm), na.rm = TRUE),
            vol.equal = sum(depth.cm == lag(depth.cm), na.rm = TRUE),
            depth.absol = sum(depth.total, na.rm = TRUE),
            depth.relat = sum(depth.fluct, na.rm = TRUE))

# bromeliad measurements, given the characteristics of each tank ----------

concord.extreme<-hidrologia.tanque %>%
  group_by(treatment) %>%
  summarise(brom.amp.total = max(prof.max)-min(prof.min), #total difference in amplitude among tanks of the same bromeliad
            brom.amp.mean = mean(amplitude), #mean amplitude between the maximum and minimum water level independent of the tank
            days.dry.max = max(days.dry), #maximum number of days any one tank was dry
            n.drytanks = sum(days.dry > 0), #number of tanks the dried out during observation
            dryness.mean = mean(dryness), #mean water depth in relation to the maximum
            mean.var.dentro = mean(var.prof), #mean variability of water depth within tanks from the same bromeliad
            var.prof.mean = var(prof.mean), #variability of water depth among tanks from the same bromeliad
            #how variable was the responses within the same bromeliad?
            var.vol.up = var(vol.up),
            var.vol.down = var(vol.down),
            var.vol.equal = var(vol.equal),
            mean.depth.absol = mean(depth.absol),
            mean.depth.relat = mean(depth.relat))

# when did the bromeliad last dried? --------------------------------------

secou<-depth %>% #take water depth
  select(day, treatment, predator, rain, numb.cup, cup, block, depth.cm) %>% #get these variables
  group_by(treatment, numb.cup) %>% #for treatment within each bromeliad
  mutate(prof.max = max(depth.cm), prof.min = min(depth.cm)) %>%  #calculate de max and min water depth
  filter(depth.cm == prof.min) %>% #show me only the data from the days where water depth was the minimum
  mutate(times.min = length(day), last.min = max(day)) %>% #how many times did the bromeliad got to its min depth and when was the last time it occurred?
  mutate(days.since = 39-last.min) %>% #how many days since it got to min water depth?
  summarise(timesmin = min(times.min), lastmin = min(last.min), #give me just what I need
            dayssince = min(days.since)) %>%
  mutate(trt = treatment) %>%
  separate(trt, into = c("predador", "chuva", "block"), sep=c(1,2))

boxplot(timesmin ~ chuva, data=secou)
boxplot(lastmin ~ chuva, data=secou)
boxplot(dayssince ~ chuva, data=secou)


# summarise 'secou' to fit in models --------------------------------------

get.dry<-secou %>%
  group_by(treatment) %>%
  summarise(mean.times.min = round(mean(timesmin)), max.times.min = max(timesmin),
            mean.last.min = round(mean(lastmin)), max.last.min = max(lastmin),
            mean.days.since = round(mean(dayssince)), max.days.since = max(dayssince),
            times.min = sum(timesmin))
#mean.anything = mean number of:
#timesmin = days the bromeliad had the lowest depth
#lastmin = the last day the bromeliad had the lower depth
#dayssince = time since the last day the bromeliad had the lower depth


# take measurements considering the all bromeliad -------------------------

hidrologia.bromelia<-depth %>%
  group_by(treatment) %>%
  summarise(prof.max = max(depth.cm),
            prof.min = min(depth.cm), prof.mean = mean(depth.cm),
            var.prof = var(depth.cm), sd.prof = sd(depth.cm),
            prof.cv = (100*(sd(depth.cm))/mean(depth.cm)),
            depth.brom.absol = sum(depth.cm - lag(depth.cm), na.rm = TRUE),
            depth.brom.relat = sum(abs(depth.cm - lag(depth.cm)), na.rm = TRUE)) %>%
  inner_join(concord.extreme) %>%
  inner_join(n.dry) %>%
  inner_join(get.dry)

setwd("..//Input/")
write.table(hidrologia.bromelia, "hidrologia da brom?lia.xls", sep="\t", row.names = FALSE)


# analysis on water depth measurements ------------------------------------


# pca measure of hydrological stability -----------------------------------

hidro.rda<-hidrologia.bromelia %>%
  select(var.prof, brom.amp.total, dryness.mean, times.min, mean.depth.relat, mean.depth.absol)
row.names(hidro.rda)<-hidrologia.bromelia$treatment
rda1<-rda(scale(hidro.rda))
plot(rda1)

size.rda<-rda(scale(environ[,c(5,7)]))

dados <- environ %>%
  mutate(pc1 = as.vector(scores(rda1, choices=1)$sites),
         pc2 = as.vector(scores(rda1, choices=2)$sites),
         brom.size = as.vector(scores(size.rda, choices=1)$sites))


# effects of rainfall on stability ----------------------------------------

ggplot(dados, aes(x=chuva, y=pc1)) +
  stat_summary(fun.data="mean_cl_boot", size=1) +
  theme_bw() +
  ylab("Hydrological Stability") +
  xlab("Predator Treatment") +
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())

#data distribution
descdist(dados$pc1, boot=1000)

model1<-lmer(pc1 ~ chuva+(1|bloco), data=dados)
model1@theta
qqnorm(resid(model1, type="deviance"));qqline(resid(model1, type="deviance"))
plot(resid(model1, type="deviance") ~ bloco, data=dados)
plot(resid(model1, type="deviance") ~ chuva, data=dados)
plot(resid(model1, type="deviance") ~ volume, data=dados)
plot(resid(model1, type="deviance") ~ volplanta, data=dados)
plot(resid(model1, type="deviance") ~ brom.size, data=dados)

ggplot(dados, aes(x=volplanta, y=pc1)) +
  stat_smooth(method = glm, formula= y ~ x) +
  geom_point() +
  theme_bw() +
  ylab("Hydrological Stability") +
  xlab("Plant Volume") +
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())

model2<-lmer(pc1 ~ chuva+(1|bloco)+volplanta, data=dados)
model2@theta
qqnorm(resid(model2, type="deviance"));qqline(resid(model2, type="deviance"))
plot(resid(model2, type="deviance") ~ bloco, data=dados)
plot(resid(model2, type="deviance") ~ chuva, data=dados)
plot(resid(model2, type="deviance") ~ volume, data=dados)
plot(resid(model2, type="deviance") ~ volplanta, data=dados)
plot(resid(model2, type="deviance") ~ brom.size, data=dados)

ggplot(dados, aes(x= brom.size, y=pc1)) +
  stat_smooth(method = glm, formula= y ~ x) +
  geom_point() +
  theme_bw() +
  ylab("Hydrological Stability") +
  xlab("Bromeliad Size") +
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())

model3<-lmer(pc1 ~ chuva+(1|bloco)+brom.size, data=dados)
model3@theta
qqnorm(resid(model3, type="deviance"));qqline(resid(model3, type="deviance"))
plot(resid(model3, type="deviance") ~ bloco, data=dados)
plot(resid(model3, type="deviance") ~ chuva, data=dados)
plot(resid(model3, type="deviance") ~ volume, data=dados)
plot(resid(model3, type="deviance") ~ volplanta, data=dados)
plot(resid(model3, type="deviance") ~ brom.size, data=dados)

ggplot(dados, aes(x=volplanta, y=volume)) +
  stat_smooth(method = glm, formula= y ~ x) +
  geom_point() +
  theme_bw() +
  ylab("Volume") +
  xlab("Volume da Planta") +
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())

model4<-lmer(pc1 ~ chuva+(1|bloco)+volume, data=dados)
model4@theta
qqnorm(resid(model4, type="deviance"));qqline(resid(model4, type="deviance"))
plot(resid(model4, type="deviance") ~ bloco, data=dados)
plot(resid(model4, type="deviance") ~ chuva, data=dados)
plot(resid(model4, type="deviance") ~ volume, data=dados)
plot(resid(model4, type="deviance") ~ volplanta, data=dados)
plot(resid(model4, type="deviance") ~ brom.size, data=dados)

ggplot(dados, aes(x=volume, y=pc1)) +
  stat_smooth(method = glm, formula= y ~ x) +
  facet_wrap(~ chuva) +
  theme_bw() +
  ylab("Hydrological Stability") +
  xlab("Volume") +
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())

model4a<-lmer(pc1 ~ volume+(1|bloco), data=dados)
model4a@theta
qqnorm(resid(model4a, type="deviance"));qqline(resid(model4a, type="deviance"))
Anova(model4a, type="II")

model4b<-lmer(pc1 ~ volume+chuva+(1|bloco), data=dados)
model4b@theta
qqnorm(resid(model4b, type="deviance"));qqline(resid(model4b, type="deviance"))
Anova(model4b, type="II")

model4c<-lmer(pc1 ~ volume+volplanta+(1|bloco), data=dados)
model4c@theta
qqnorm(resid(model4c, type="deviance"));qqline(resid(model4c, type="deviance"))
Anova(model4c, type="II")

model4d<-lmer(pc1 ~ volume+volplanta*chuva+(1|bloco), data=dados)
model4d@theta
qqnorm(resid(model4d, type="deviance"));qqline(resid(model4d, type="deviance"))

model4e<-lmer(pc1 ~ volume+chuva+sqrt(volplanta)+(sqrt(volplanta)|bloco), data=dados)
model4e@theta
qqnorm(resid(model4e, type="deviance"));qqline(resid(model4e, type="deviance"))

anova(model4, model4a, model4b, model4c, model4d, model4e)

#model4a (volume e bloco) e model4c (volume e volume da planta, bloco)

summary(model4d)
Anova(model4d, type="III")

xvp<-range(dados$volplanta)
xsvp<-seq(from = xvp[1], to = xvp[2], length=1500)

slop4c<-as.vector(summary(model4d)$coefficients[3,1]) #slope
slop.se4c<-as.vector(summary(model4d)$coefficients[3,2]) #slope se
int4c<-summary(model4d)$coefficients[1,1] #intercept
int.se4c<-summary(model4d)$coefficients[1,2] #se intercept

reg4c<-data.frame(eixox = xsvp) %>%
  mutate(slop = int4c+eixox*slop4c,
         up1 = (int4c+(int.se4c*1.96))+(eixox*(slop4c+(slop.se4c*1.96))),
         down1 = (int4c-(int.se4c*1.96))+(eixox*(slop4c-(slop.se4c*1.96))))

xvol<-range(dados$volume)
xsvol<-seq(from = xvol[1], to = xvol[2], length=1500)
predict(model4d, se.fit = TRUE)
slop4d<-as.vector(summary(model4d)$coefficients[2,1]) #slope
slop.se4d<-as.vector(summary(model4d)$coefficients[2,2]) #slope se

reg4d<-data.frame(eixox = xsvol) %>%
  mutate(slop = int4c+eixox*slop4d,
         up1 = (int4c+(int.se4c*1.96))+(eixox*(slop4d+(slop.se4d*1.96))),
         down1 = (int4c-(int.se4c*1.96))+(eixox*(slop4d-(slop.se4d*1.96))))

# old stuff ---------------------------------------------------------------


# fit distribution to water depth measurements ----------------------------

library(fitdistrplus)
descdist(depth$depth.cm, boot=10000)

# Andrew's stuff ----------------------------------------------------------

library(ggplot2)

hidrologia %>%
  ungroup %>%
  tidyr::separate(col = treatment, into = c("treat", "repl"), sep = -2) %>%
  ggplot(aes(x = prof.mean, y = var.prof, colour = repl)) +
  geom_point() +
  facet_wrap(~treat) +
  stat_smooth(method = "lm")

# trying to fit a model to get the slope per tank -------------------------

model1<-lme(depth.cm ~ day, random = ~0+numb.cup|treatment,
            correlation = corAR1(form= ~1|treatment),
            data=depth)
AIC(model1)
summary(model1)
sresid<-resid(model1, type="normalized")
hist(sresid)
qqnorm(sresid);qqline(sresid)
slope.cup<-ranef(model1)
slope.cup
hidrologia<-with(hidrologia, hidrologia[order(numb.cup),])


library(reshape2)
slopes<-melt(slope.cup)

hidrologia$slopes<-slopes[,2]
hidrologia$chuva<-rep(c("controle", "dry", "wet"), 3, each=7)

#para slopes do copo central e copo lateral ------------------------------
model2<-lme(depth.cm ~ day, random = ~0+cup|treatment,
                    correlation = corAR1(form= ~1|treatment),
                    data=depth)
AIC(model2)
summary(model2)
sresid<-resid(model2, type="normalized")
hist(sresid)
qqnorm(sresid);qqline(sresid)
slope.cup2<-ranef(model2)
slope.cup2

# make data frame with pooled data for lateral vs central -----------------

hidro.lat.cent<-depth %>%
  group_by(treatment, cup, numb.cup) %>%
  summarise(profmax = max(depth.cm),
            profmin = min(depth.cm), profmean = mean(depth.cm),
            varprof = var(depth.cm), sdprof = sd(depth.cm),
            profcv = (100*(sd(depth.cm))/mean(depth.cm)),
            overflowdays = sum(depth.cm == max(depth.cm))-1,
            deadvoldays = sum(depth.cm == min(depth.cm)),
            daysdry = sum(depth.cm == 0),
            volup = sum(depth.cm > lag(depth.cm), na.rm=TRUE),
            voldown = sum(depth.cm < lag(depth.cm), na.rm = TRUE),
            volequal = sum(depth.cm == lag(depth.cm), na.rm = TRUE)) %>%
  group_by(treatment,cup) %>%
  summarise(prof.max = mean(profmax), prof.min = mean(profmin),
            prof.mean = mean(profmean), var.prof = mean(varprof),
            sd.prof = mean(sdprof), prof.cv = mean(profcv),
            overflow.days = mean(overflowdays),
            deadvol.day = mean(deadvoldays),
            days.dry = mean(daysdry),
            vol.up = mean(volup),
            vol.down = mean(voldown),
            vol.equal = mean(volequal))

lat.cent<-with(lat.cent.pooled, lat.cent.pooled[order(cup),])
lat.cent$chuva<-rep(c("controle", "dry", "wet"), 6, each=7)
lat.cent$slop<-c(slope.cup2[,1],slope.cup[,2])
head(lat.cent)
head(slope.cup2)

lat.cent<-as.data.frame(lat.cent)
rda3<-rda(scale(lat.cent[,c(3:14,16)]) ~ chuva+cup, data=lat.cent)
plot(rda3, scaling=3, display=c("species", "cn"))

write.table(hidro.lat.cent, "hidrologia do central e laterais.xls", sep="\t", row.names = FALSE)

# make data frame with data for the central and lateral cups --------------
hidro.tanques<-depth %>%
  group_by(treatment, cup) %>%
  summarise(prof.max = max(depth.cm),
            prof.min = min(depth.cm), prof.mean = mean(depth.cm),
            var.prof = var(depth.cm), sd.prof = sd(depth.cm),
            prof.cv = (100*(sd(depth.cm))/mean(depth.cm)),
            overflowdays = mean(depth.cm == max(depth.cm)),
            deadvoldays = mean(depth.cm == min(depth.cm)),
            days.dry = mean(depth.cm == 0),
            volup = mean(depth.cm > lag(depth.cm), na.rm=TRUE),
            voldown = mean(depth.cm < lag(depth.cm), na.rm = TRUE),
            volequal = mean(depth.cm == lag(depth.cm), na.rm = TRUE))


# try to fit a distribution to data ---------------------------------------

library(fitdistrplus)

teste<-depth %>%
  filter(treatment =="AD1")

descdist(teste$depth.cm, boot = 1000)

model1<-fitdist(teste$depth.cm)
model1.boot<-bootdist(model1)
head(model1.boot)
summary(model1)
plot(model1)
plot(model1, demp=TRUE)
plot(model1, histo=FALSE, demp=TRUE)
cdfcomp(model1, addlegend=FALSE)
denscomp(model1, addlegend=FALSE)
ppcomp(model1, addlegend=FALSE)
qqcomp(model1, addlegend=FALSE)

# outros ------------------------------------------------------------------

lat.cent.mean<-depth %>%
  group_by(treatment, cup, numb.cup) %>%
  summarise(profmax = max(depth.cm),
            profmin = min(depth.cm), profmean = mean(depth.cm),
            varprof = var(depth.cm), sdprof = sd(depth.cm),
            profcv = (100*(sd(depth.cm))/mean(depth.cm)),
            overflowdays = sum(depth.cm == profmax)-1,
            deadvoldays = sum(depth.cm == profmin),
            daysdry = sum(depth.cm == 0),
            volup = sum(depth.cm > lag(depth.cm), na.rm=TRUE),
            voldown = sum(depth.cm < lag(depth.cm), na.rm = TRUE),
            volequal = sum(depth.cm == lag(depth.cm), na.rm = TRUE)) %>%
  group_by(treatment,cup) %>%
  summarise(prof.max = mean(profmax), prof.min = mean(profmin),
            prof.mean = mean(profmean), var.prof = mean(varprof),
            sd.prof = mean(sdprof), prof.cv = mean(profcv),
            overflow.days = mean(overflowdays), deadvol.day = mean(deadvoldays),
            days.dry = mean(daysdry), vol.up = mean(volup), vol.down = mean(voldown),
            vol.equal = mean(volequal))

lat.cent<-with(lat.cent.mean, lat.cent.mean[order(cup),])
lat.cent$chuva<-rep(c("controle", "dry", "wet"), 6, each=7)
lat.cent$slop<-c(slope.cup2[,1],slope.cup2[,2])
head(slope.cup2)

lat.cent<-as.data.frame(lat.cent)
rda3<-rda(scale(lat.cent[,c(3:14,16)]) ~ chuva+cup, data=lat.cent)
plot(rda3, scaling=3, display=c("species", "cn"))

write.table(lat.cent, "hidro.xls", sep="\t")



# what does the rainfall distribution mean? -------------------------------

#rainfall is the data frame I am working on
#it describes the rainfall pattern imposed in the experiment
#the columns in the data frame are
#tratamento = the rainfall treatment (categorical)
#dia = the the day of the experiment (numerical)
#precipitacao = how much water was added in each day (numerical)
head(rainfall)


#function to calculate the length of a sequence of zeroes in a vector
testvec <- rnbinom(30,size = 1, prob = 0.8)

#a function to count the largest number of zeros in a seq
#by Andrew MacDonald
n_max_zero <- function(vec){
  testvec_list <- rle(vec)
  where_zero <- which(testvec_list$values == 0)
  testvec_list$lengths[where_zero]
}
testvec
n_max_zero(testvec)

#pipe the function to get the total number and duration of chunks of zero rain
zerodays<-rainfall %>%
  filter(dia > 12) %>% #exclude the initial days, since all treatments share the initial period of no rain (we did it that way)
  group_by(tratamento) %>%
  do(nzero = n_max_zero(.$precipitacao)) %>%
  mutate(max_seq = max(nzero), zero_events = length(nzero),
         sdzero = sd(nzero, na.rm=TRUE), meanzero = mean(nzero))

#given the control treatment, what is the distribution of rainfall?
rain_control <- rainfall %>%
  filter(precipitacao > 0, tratamento =="Controle") %>%
  summarise(quantile10 = quantile(precipitacao, 0.1),
            quantile25 = quantile(precipitacao, 0.25),
            quantile50 = quantile(precipitacao, 0.5),
            quantile75 = quantile(precipitacao, 0.75),
            quantile90 = quantile(precipitacao, 0.9))

#create a data frame only with the days that rained
rains <- rainfall %>%
  filter(precipitacao > 0) %>%
  group_by(tratamento) %>%
  summarise(small.event = sum(precipitacao <= rain_control$quantile10),
            event.25 = sum(precipitacao > rain_control$quantile10 & precipitacao <= rain_control$quantile25),
            event.50 = sum(precipitacao > rain_control$quantile25 & precipitacao <= rain_control$quantile50),
            event.75 = sum(precipitacao > rain_control$quantile50 & precipitacao <= rain_control$quantile75),
            event.90 = sum(precipitacao > rain_control$quantile75 & precipitacao <= rain_control$quantile90),
            big.event = sum(precipitacao > rain_control$quantile90),
            total.rainfall = sum(precipitacao), rain_event = mean(precipitacao),
            max_event = max(precipitacao), min_event = min(precipitacao),
            q10 = mean(quantile(precipitacao, 0.1)),
            q25 = mean(quantile(precipitacao, 0.25)),
            q50 = mean(quantile(precipitacao, 0.5)),
            q75 = mean(quantile(precipitacao, 0.75)),
            q90 = mean(quantile(precipitacao, 0.9))) %>%
  left_join(zerodays)
head(rains)

#now, with your data in hand, summarise the characteristics of your rainfall
#distribution
raindist <- rainfall %>%
  group_by(tratamento) %>%
  summarise(no_rain = sum(precipitacao == 0), yes_rain = sum(precipitacao > 0)) %>%
  left_join(rains) %>%
  mutate(prop.small = round(small.event/yes_rain, digits = 2),
         prop.25 = round(event.25/yes_rain, digits = 2),
         prop.50 = round(event.50/yes_rain, digits = 2),
         prop.75 = round(event.75/yes_rain, digits = 2),
         prop.90 = round(event.90/yes_rain, digits = 2),
         prop.big = round(big.event/yes_rain, digits = 2))
raindist

raindist %>%
  mutate(total = no_rain+yes_rain) %>%
  ggplot(aes(x = tratamento)) +
  geom_bar(aes(weight = total, fill = as.factor(yes_rain)), position = "fill")

setwd("../Resultados/")
write.table(raindist, "raindist.xls", sep="\t", row.names = FALSE)

#no_rain = number of days with no rainfall
#yes_rain = number of days with rainfall
#small.event = number of small precipitation events (departing from control)
#event.25 = number of precipitation events between 10% and 25% quantile (departing from control)
#event.50 = number of precipitation events between 25% and 50% quantile (departing from control)
#event.75 = number of precipitation events between 50% and 75% quantile (departing from control)
#event.90 = number of precipitation events between 75% and 90% quantile (departing from control)
#big.event = number of precipitation events greater than 90% quantile (departing from control)
#total.rainfall = total volume of water added to the plant
#rain_event = mean volume of water added to the plant per event
#max_event = maximum volume of water added to the plant in a single event
#min_event = minimum volume of water added to the plant in a single event
#q10 = size of a small precipitation event for that treatment
#q25 = size of a precipitation even smaller than the 25% quantile for that treatment
#q50 = size of a precipitation even smaller than the 50% quantile for that treatment
#q75 = size of a precipitation even smaller than the 75% quantile for that treatment
#q90 = size of a precipitation even smaller than the 90% quantile for that treatment
#max_seq = maximum length of days where the plant received no water
#zero_events = number of times where the plant received no water
#sdzero = standard deviation of the number of days where the plant got no water
#meanzero = mean number of days where the plant got no water
#prop.x = proportion of events on the x size quantile

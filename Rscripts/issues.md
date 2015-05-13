
#Issues with the datasets

## site.info

* *Colombia* format of this tab is incorrect -- too many rows
* *PuertoRico* apostrophe in number column 2, 3 and 4
* *FrenchGuiana* empty rows below data

## site.weather

* *Argentina* there is an empty column immediately to the right

## bromeliad.physical

* *Argentina* incorrectly formatted values in row 15 column 29 and 30
* *Colombia* unnamed blank cells next door
(this latter error is critical. it prevents specifying the coltypes, necessary for the mix of data types of bromeliad ids)

## bromeliad.final.inverts

* *Argentina* incorrect top of sheet - should be only one line
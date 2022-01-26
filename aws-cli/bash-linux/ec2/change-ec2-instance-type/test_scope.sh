var_change2 () {
var1='1 in var_change2'
echo Inside var_change2: var1 is $var1 : var2 is $var2
var1='1 in var_change2 changed again'
var2='2 in var_change2 changed again'
}
var_change () {
local var1='local 1'
echo Inside function: var1 is $var1 : var2 is $var2
var1='changed again'
var2='2 changed again'
}
var1='global 1'
var2='global 2'
echo Before function call: var1 is $var1 : var2 is $var2
var_change
echo Before function varchange2: var1 is $var1 : var2 is $var2
var_change2
echo After function call: var1 is $var1 : var2 is $var2

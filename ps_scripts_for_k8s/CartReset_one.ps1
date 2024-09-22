# The $null is so that memory in the variables isn't cached.
$Pods = $null
$Region = $null
$Region = Read-Host -Prompt 'Input region name'
$Pods = kubectl get pods -n cart -o=custom-columns=NAME:.metadata.name --context $Region
foreach ($Items in $Pods) {
write-host "kubectl delete pod -n cart --context" $Region $Items
start-sleep -seconds 5
}
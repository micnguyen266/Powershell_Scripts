$DC = ("dublin", "frankfurt", "hongkong", "norcal", "seoul", "tokyo", "virginia")
foreach ($Region in $DC){
$Pods = $null
$Pods = kubectl get pods -n cart -o=custom-columns=NAME:.metadata.name --context $Region
foreach ($Items in $Pods) {
  write-host "kubectl delete pod -n cart --context" $Region $Items
start-sleep -seconds 5
}}
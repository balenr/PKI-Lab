New-AzResourceGroup -Name 'PKI-Lab' -Location 'West Europe'

# New-AzResourceGroupDeployment -ResourceGroupName 'PKI-Lab' `
#     -TemplateFile './infrastructure/core.bicep' `
#     -TemplateParameterFile './configurations/dev.json' `
#     -Whatif

New-AzResourceGroupDeployment -ResourceGroupName 'PKI-Lab' `
    -TemplateFile './infrastructure/vm.bicep' `
    -TemplateParameterFile './configurations/dev-vm.json' `
    -Whatif

$vmAdminPassword = ConvertTo-SecureString $env:AZURE_VM_PASSWORD -AsPlainText -Force

New-AzResourceGroupDeployment -ResourceGroupName 'PKI-Lab' `
    -TemplateFile './main.bicep' `
    -TemplateParameterFile './configurations/dev.json' `
    -vmAdminPassword $vmAdminPassword `
    -Whatif

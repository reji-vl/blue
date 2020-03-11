variable "loca"{
	default = "West US 2"
}

provider "azurerm"{
	subscription_id = "3ff709d1-14a1-4488-98a8-428d74bfd43d"
	client_id = "f0b4c9c4-67b6-45b2-bc08-49b694219a02"
	client_secret = "d84a891d-c280-46e8-97fd-9f0c2e1672f0"
	tenant_id = "105b2061-b669-4b31-92ac-24d304d195dc"
	features {}
}

resource "azurerm_resource_group" "test_blue"{
	name = "testblue"
	location = var.loca
}

resource "azurerm_virtual_network" "test_blue_net"{
	name="testbluenet"
	resource_group_name = azurerm_resource_group.test_blue.name
	address_space = ["10.0.0.0/24"]
	location = var.loca	
}

resource "azurerm_subnet" "test_blue_sub"{
	name = "testbluesub"
	resource_group_name = azurerm_resource_group.test_blue.name
	virtual_network_name = azurerm_virtual_network.test_blue_net.name
	address_prefix = "10.0.0.0/24"
}

resource "azurerm_network_interface" "test_net_iface"{
	name = "testnetiface"
	resource_group_name = azurerm_resource_group.test_blue.name
	location = var.loca
	
	ip_configuration{	
		name = "eth0"
		subnet_id = azurerm_subnet.test_blue_sub.id
		private_ip_address_allocation = "Dynamic"
	}

}

resource "azurerm_virtual_machine" "test_blue_vm"{
	name = "testbluevm"
	resource_group_name = azurerm_resource_group.test_blue.name
	location = var.loca
	network_interface_ids = ["${azurerm_network_interface.test_net_iface.id}"]
	vm_size = "Standard_DS1_v2"
	
	storage_image_reference{
		publisher = "canonical"
		offer = "UbuntuServer"
		sku = "16.04-LTS"
		version = "latest"
	}
	
	storage_os_disk{
		name = "testblueos"
		create_option = "FromImage"
		caching = "ReadWrite"
		managed_disk_type = "Standard_LRS"
		
	}
	
	os_profile{
		computer_name = "testbluecompute"
		admin_username = "testadmin"
		admin_password = "Testpass@12"
	}
	
	os_profile_linux_config{
		disable_password_authentication = false
	}
}

output "Network_ip_assigned"{
	value = azurerm_network_interface.test_net_iface.private_ip_address
}

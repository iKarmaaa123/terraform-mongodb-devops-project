package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestMongoDBProjectName(t *testing.T) {
	// Give a name to your MongoDB project
	expectedProjectName := "terraformProject"

	// Terraform options with the path to your Terraform code that defines your MongoDB project
	terraformOptions := &terraform.Options{
		// Set the path to the Terraform code directory
		TerraformDir: "examples/cluter/cluster.tf",
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// Deploy the Terraform stack
	terraform.InitAndApply(t, terraformOptions)

	// Get the project name from the Terraform output
	projectName := terraform.Output(t, terraformOptions, "project_name")

	// Verify that the actual project name matches the expected project name
	assert.Equal(t, expectedProjectName, projectName, "MongoDB project name does not match the expected name")
}

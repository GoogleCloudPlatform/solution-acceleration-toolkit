# Terraform Engine Components

Components are the building blocks of the Terraform Engine. They typically
define templatized Terraform configs which the engine then sends values to.

One component defines only one Terraform deployment. It may define a partial
deployment and expect other components to fill in any missing parts.
Typically this is done through [recipes](../recipes).

Users can modify the components and add their own if they wish to do so in their
own forks.

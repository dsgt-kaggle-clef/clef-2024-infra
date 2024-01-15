# Onboarding Documentation for Development Setup

## 1. Logging into GCP VM using VS Code with SSH Extension

This section provides a detailed guide on how to log into a Google Cloud Platform (GCP) Virtual Machine (VM) using Visual Studio Code (VS Code) with the SSH extension. This process involves several steps, including setting up the GCP command-line tools, starting the VM, and connecting via VS Code.

### Prerequisites

- **Google Cloud Account:** Ensure you have access to a Google Cloud account and the necessary permissions to manage VM instances.
- **GCP Project:** Identify the GCP project where your VM is located.

### Step 1: Install Google Cloud SDK (gcloud)

**Run Locally**

If you don't have the Google Cloud SDK installed, follow these steps:

1. **Download and Install:** Visit the [Google Cloud SDK page](https://cloud.google.com/sdk/docs/install-sdk) and follow the instructions to download and install the SDK for your operating system.
2. **Initialize gcloud:** Run `gcloud init` in your local terminal. Follow the prompts to log in to your Google account and set your default project.


### Step 2: Start the GCP VM Instance

**Run Locally**

1. **Set the Project:** Run the following command to set your active project to `dsgt-clef-2024`:
```
gcloud config set project dsgt-clef-2024
```

This command configures `gcloud` to use the specified project for all subsequent commands.

2. **Define Your Instance:** Assign your instance name to a variable for ease of use:
```
instance=birdclef-dev
```

3. **Start Your Instance:** Start your VM using the following command:
```
gcloud compute instances start ${instance}
```

4. **Configure SSH:** This step helps to simplify the SSH connection process:
```
gcloud compute config-ssh
```

This command updates your local SSH configuration file with the details of the GCP instance.


### Step 3: Install Visual Studio Code and SSH Extension

**Run Locally**

1. **Install VS Code:** If you don't have it, download and install Visual Studio Code from the [official website](https://code.visualstudio.com/download).
2. **Install Remote - SSH Extension:** Open VS Code, go to the Extensions view by clicking on the square icon on the sidebar, or pressing `Ctrl+Shift+X`, and search for "Remote - SSH". Install the extension.

### Step 4: Connect to the VM using VS Code

**Run in VS Code**

1. **Open the Command Palette:** Press `Ctrl+Shift+P` or `Cmd+Shift+P` to open the command palette.
2. **Initiate SSH Connection:** Type 'Remote-SSH: Connect to Host' and press Enter.
3. **Select Your VM Instance:** Choose the VM instance you configured earlier. It should appear in the list due to the previous `gcloud compute config-ssh` command.
4. **Verify Connection:** Once connected, a new VS Code window will open, connected to your VM. Open a terminal inside VS Code (Terminal > New Terminal) to verify you're logged into the VM.

### Step 5: Stopping the GCP VM Instance (Optional)

**Run Locally**

After you're done working, make sure to stop your instance and save resources when not in use:
```
gcloud compute instances stop ${instance}
```

This should enable you to set up and log into your GCP VM using VS Code with the SSH extension, ensuring a smooth remote development experience.


<!---
## Logging into a GCP VM

I recommend using VSCode with the SSH extension, which will allow you to develop seamlessly with all the amenities you might expect locally.
It also has nice port forwarding functionality -- this is super handy on Windows.

```bash
# alternatively, set --project dsgt-clef-2024 on each gcloud command
gcloud config set project dsgt-clef-2024

instance=birdclef-dev

# start your instance
gcloud compute instances start ${instance}

# configure ssh in your ~/.ssh/config to use a simple host name
gcloud compute config-ssh 

# stop your instance when you're done
gcloud compute instances stop ${instance}
```

## Configuring your git repository

Auth into github using a new SSH key.
**Use a secure password on the SSH key!**
Everyone on the project will be able to SSH into your machine, so you want to ensure that your private key associated with your github cannot be used to push arbitrary code.
Clone the project, and get started.
Configure git with your identity:

```bash
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
```

You may also want to use `vim` as your default git editor.
The default is `nano`.

```bash
git config --global core.editor "vim"
```

Authenticate with GitHub using the `gh` tool.

```bash
gh auth login
```

I suggest authenticating via SSH with a private key using a secure password/passphrase.
If you choose https authentication, the authentication key is stored locally in plain-text.
Other users who can log into the VM will be able to see the file.
If you decided to go this route, make sure to run `gh auth logout`. 

Clone your repository and start working!
-->

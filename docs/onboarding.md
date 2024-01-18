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

If you already have Google Cloud SDK installed, make sure that you have activated the account that has an access to the GCP project by running `gcloud auth list` command.


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

3. **Review Your Dafault Zone Setting:** If you have never configured the zone before, Google Cloud CLI will automatically set it to the instance's zone. If you have configured a default zone previously, you can reconfigure it by running the following command: 
```
gcloud config set compute/zone us-central1-a
```

4. **Start Your Instance:** Start your VM using the following command:
```
gcloud compute instances start ${instance}
```

5. **Configure SSH:** This step helps to simplify the SSH connection process:
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

### Step 5: Stopping the GCP VM Instance

**Run Locally**

After you're done working, make sure to stop your instance and save resources when not in use:
```
gcloud compute instances stop ${instance}
```

This should enable you to set up and log into your GCP VM using VS Code with the SSH extension, ensuring a smooth remote development experience.

## 2. Authenticating to GitHub using GitHub CLI

This section streamlines the authentication process to GitHub using the GitHub CLI (`gh`), which simplifies the SSH setup. These steps should be executed within the Virtual Machine (VM) accessed through VS Code.

### Prerequisites

- **Access to the VM:** Ensure you're logged into your GCP VM via VS Code as described in the previous section.
- **GitHub Account:** A GitHub account is required for authentication.

### Step 1: Authenticate with GitHub using GitHub CLI

**Run in VM (VS Code Terminal)**

1. **Start the Authentication Process:** Run `gh auth login` to begin the authentication process.

2. **Choose SSH for Git Operations:** When prompted, select SSH as the preferred protocol for Git operations.

3. **Generate a New SSH Key (if required):** If you don't already have an SSH key, `gh` will prompt you to generate one. Follow the on-screen instructions to create a new SSH key.

4. **Authenticate Your SSH Key with GitHub:** `gh` will automatically add your SSH key to your GitHub account. Follow any additional prompts to complete the process.

5. **Verify Authentication:** After completing the setup, run `gh auth status` to check if you're successfully authenticated.

### Step 2: Verify GitHub User Information (Optional)

**Run in VM (VS Code Terminal)**

It's good practice to ensure your Git identity is correctly set:

1. **Check Git Configurations:** Run `git config --list` to see your Git configurations, including user name and email.

2. **Set Git User Information If Not Set:** If not already set, configure your Git user information:

```
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
```
Replace with your GitHub email and name.

### Step 5: Test GitHub Connection

**Run in VM (VS Code Terminal)**

1. **SSH Connection Test:** To confirm that your SSH setup is working, run `ssh -T git@github.com`. You should receive a message confirming successful authentication.

2. **Test Git Operations:** Try a simple Git operation, like `git fetch`, to ensure everything is working correctly.


<!--
## 2. Authenticating into GitHub Using a New SSH Key

This section focuses on setting up SSH-based authentication for GitHub. It includes steps to generate a new SSH key, add it to your GitHub account, and verify if this setup is already correctly done. These steps are to be executed within the Virtual Machine (VM) accessed through VS Code.

### Prerequisites

- **Access to the VM:** Ensure you've successfully logged into your GCP VM using VS Code as outlined in the previous section.
- **GitHub Account:** You should have a GitHub account where you can add the SSH key.

### Step 1: Check Existing SSH Keys in the VM

**Run in VM (VS Code Terminal)**

Before generating a new SSH key, check if you already have an existing SSH key in the VM:

1. **List SSH Keys:** Run `ls -al ~/.ssh` to list all files in your `.ssh` directory. Look for files named `id_rsa.pub` or `id_ed25519.pub`. These are public SSH keys.
2. **Skip Key Generation If Exists:** If such a file exists and you prefer to use it, skip to Step 3. Otherwise, proceed to generate a new key.

### Step 2: Generate a New SSH Key

**Run in VM (VS Code Terminal)**

If you don't have an existing SSH key or wish to create a new one:

1. **Generate SSH Key:** Run `ssh-keygen -t rsa -b 4096 -C "your_email@example.com"`, replacing `your_email@example.com` with your GitHub email. Press Enter to accept the default file location.
2. **Set a Secure Passphrase:** When prompted, enter a secure passphrase for the key.

### Step 3: Add the SSH Key to Your GitHub Account

**Run in VM (VS Code Terminal)**

1. **Copy the SSH Key:** Run `cat ~/.ssh/id_rsa.pub` (or `id_ed25519.pub` if you used `Ed25519`) to display your public key. Copy this key to your clipboard.
2. **Add Key to GitHub:** Go to your GitHub account settings, navigate to "SSH and GPG keys", and click on "New SSH key". Paste your key here and save it.

### Step 4: Verify SSH Connection to GitHub

**Run in VM (VS Code Terminal)**

To ensure your SSH setup is correct:

1. **Test SSH Connection:** Run `ssh -T git@github.com`. You should receive a message confirming your authentication.
2. **Accept GitHub's Host Key:** If prompted to verify the authenticity of the GitHub host, type yes to continue.

### Step 5: Configure GitHub User Information

**Run in VM (VS Code Terminal)**

It's important to set your Git identity in the VM:

1. **Configure Git Email:** Run `git config --global user.email "you@example.com"`, replacing with your GitHub email.
2. **Configure Git Name:** Run `git config --global user.name "Your Name"`, replacing with your GitHub username.

### Step 6: Check Existing GitHub Authentication Status

**Run in VM (VS Code Terminal)**

1. **Check Current GitHub Authentication:** Run `gh auth status` to check if you're already authenticated with GitHub CLI.
2. **If Not Authenticated:** If you're not authenticated or wish to re-authenticate, run `gh auth login` and follow the prompts. Choose SSH for authentication.
3. **Follow On-Screen Instructions:** For SSH, you'll be guided to enter your SSH key passphrase. For HTTPS, you'll need to enter your GitHub credentials.

### Step 7: Verify Configuration

**Run in VM (VS Code Terminal)**

1. **Check Git Configurations:** Run `git config --list` to see all the Git configurations, including user name and email. Ensure they're correctly set.
2. **Try a Test Command:** Run a Git command like `git fetch` to verify that your setup works correctly with your GitHub repository.



<!--
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

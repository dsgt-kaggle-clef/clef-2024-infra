# Onboarding

## Logging into a GCP VM

Auth into github using a new SSH key.
**Use a secure password on the SSH key!**
Everyone on the project will be able to SSH into your machine, so you want to ensure that your private key associated with your github cannot be used to push arbitrary code.
Clone the project, and get started.

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

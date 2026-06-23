#Create your SSH keys
ssh-keygen -t ed25519 -C "SuperSecretHax-OrWhateverYouWant_LikeEmail_Or_Something"
# Answer the prompts, but if you're super lazy, just hit enter twice and not save a passcode for your ssh key, allowing anyone with access to it to steal and use it.

#Secure your keys
#Sets read-write-execute for the owner only.
chmod 700 ~/.ssh
#Sets read-write for the owner only
chmod 600 ~/.ssh/id_ed25519

#Add the key to your server's authorized keys file
cat id_ed25519.pub >>  ~/.ssh/authorized_keys

#Restart ssh to load the configurations on your server.
sudo systemctl restart sshd

#If on windows, copy and paste the private key below into a text file.
cat ~/.ssh/id_ed25519

#From here, open putty-gen and load the key. 
#You will then be prompted that you imported a key and to save the private key (*.ppk file) to use it with putty.
#Do that. Save the private key locally where you can find your .ppk file.
#Open up puTTY and navigate on the side bar to Connection > SSH > Auth > Credentials 
#Then in the private key for authentication, load your .ppk file with the browse button
#Before opening, navigate back to the session category, click on Default Settings or create a different setting and click on SAVE.
#If you dont do that, you'll lose your configuration and wont be able to lazily ssh into your computer.

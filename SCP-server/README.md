# SCP Server

A simple SCP encryption and decryption server pair using AES256 CTR and HMAC_SHA256, ensuring secure file transmission and integrity verification, with features for both local and remote operations.

# Summary

In this exercise, I implemented an pair of SCP encryption and decryption server. The encryption server starts by generating a key using a set of password and randomly generated salt. It then take in a file, encrypts every 1024 bytes and HMACs the encrytion, either attach the result to a file or send to remote decryption server. The decryption starts by either opening the decryption file or receiving the salt and filename from remote. It then starts reading the encrypted file every 1024 bytes + 32 bytes of HMAC, compares the HMAC then decrypts the file and stores locally.

## Encryption server

I used AES256 CTR mode for ease of implementation, as only a local counter is needed (instead of needing to send an IV) and no decryption algorithm is needed, since for CTR mode, the encryption is the same process as decryption. For HMAC, I chose HMAC_SHA256. Additionally, when generating the key using the password, we need to provide a randomly generated salt. This is to give more randomness to the key generation process, as now the same pw will not generate the same key.

In the encryption server, we start by either establishing the remote connection, and send over the generated salt and file name if a "-d" flag is supplied. Then we directly setup the encryption and HMAC handles using libgcrypt. We then store the salt into local .pur file, open the source file and start reading every 1024 bytes. For each of these bytes, we encrypt then mac them. If remote, we send to remote server, if local we store into local encrypted .pur file.

The file looks like:

64 bytes of salt -> 1024 bytes of encrypted message -> 32 bytes of HMAC -> 1024 bytes of encrypted message...32 bytes of HMAC -> remaining bytes of encrypted message -> 32 bytes of HMAC

## Decryption server

In the decryption server, if local, we read in the .pur file, reads the salt and prepare the output file. If remote, we start the socket and listen for connection: once received, we read in the filename and salt. Like the encryption server, we then setup the crypto and HMAc handles. Lastly, depending on remote or local, we either read from the file or remote server, then compare the HMAC + decrypt + send to local decrypted file.

## Makefile

In the Makefile, I make sure to install the libgcrypt library using the apt-get, then compile both c files.

# Usage

Clone repo to server. Supports Linux Ubuntu 18.04 or later.
`git clone https://github.com/bchen39/SCP-server`

## Local

Ensure that both enc and dec are in the same folder. 

```bash
make
cp dummy.txt testfile
./purenc testfile -l
rm testfile
./purdec -l testfile.pur
diff dummy.txt testfile # check difference
```

## Remote

Ensure that enc and dec are on different servers.

```bash
# On the decryption server
make
./purdec $(PORT)

# On the encryption server
make
cp dummy.txt testfile
./purenc testfile -d $(DECRYPTION_SERVER_IP):$(PORT)

# On the decryption server
diff dummy.txt testfile
```

You can replace `dummy.txt` and `testfile` with whichever name you prefer.
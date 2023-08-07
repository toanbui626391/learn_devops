#trap will waiting for for defualt SIGNINT(2) and execute echo Hello World
#we have infinate loop just waiting for another signal
#ctrl + z will send signal to stop the process and get back to cell. ctrl + z to stop process
trap "echo Hello World" SIGINT
while [[ true ]] ; do
    sleep 1
done
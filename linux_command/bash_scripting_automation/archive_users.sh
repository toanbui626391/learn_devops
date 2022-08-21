echo "Executing script: $0"
#how to access all positional starting from $1
for USER in $@
do
  echo "Archiving user: $USER"
  # Lock the account
  passwd –l $USER
  # Create an archive of the home directory.
  tar cf /archives/${USER}.tar.gz /home/${USER}
done
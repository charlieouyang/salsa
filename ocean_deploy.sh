echo "Stashing changes"
echo "."
echo "."
echo "."
git stash
echo "Done!"

echo "Pulling latest changes"
echo "."
echo "."
echo "."
git pull origin master
echo "Done!"

echo "Add back stashed changes"
echo "."
echo "."
echo "."
git stash pop
echo "Done!"

echo "Restarting services"
echo "."
echo "."
echo "."
systemctl restart salsa
systemctl restart nginx
echo "Done!"

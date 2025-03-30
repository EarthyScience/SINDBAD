# How to... merge your local branch into the master
starting in GitKraken
(working on *your branch*/your branch is check-out)
  → the icons of your local and remote branch aline

  -	**stage** all the files of your work in progress (WIP) that you want to merge to the master
  -	write a summary and a short description about the changes you made
  -	**commit** the changes
  → the icons of your local and remote branch separate

  -	**push** your local version to the remote branch
  → the icons of your local and remote branch aline again

continue on [GitLab](https://git.bgc-jena.mpg.de/sindbad/sindbad)
(working on *your branch*)
  -	**create merge request**
  -	fill in (copy the) summary and short description of your changes
  -	set target branch = master
  -	**submit merge request**

… wait for approvement


![](media/How to_merge.png)
___________

# How to... merge an updated version of the master to your local branch
starting in GitKraken
(working on the *master branch*/the master branch is check-out)
  → the icons of the local and remote master branch are separated

  -	**pull** the remote version of the master
  -	eventually, solve merge conflicts by selecting the right code
  → the icons of your local and remote branch aline again

  -	**check-out** to your branch
    -	if check-out fails due to conflicts, look at the made changes and commit, stash or discard them
  (working on *your branch*)
  -	right click on the master, choose **merge origin-master into your branch**
  → the icons of your local and remote branch separate

  -	**push** your local version to the remote branch
  → the icons of your local and remote branch aline again

# SynoSendFileChangesViaMail
Sends Filechanges in a specific folder via E-Mail on a Synology NAS

Original Source: https://community.synology.com/enu/forum/1/post/135582

Sends email to users when defined folder has been modified.
If the defined folder has not been modified, an email can be sent to the admin by setting SEND_UNCHANGED to 1.
Comparison lists can be recursive or not, depending on RECURSIVE_LIST parameter value.
Comparison is only performed on file names, and not contents.
During the first run, creates lists for comparison and store them in '/homes/admin/_nasData_scripts' folder (see REP_DATA parameter)

TODO: send difference list as attachment, as too large string sent in mail body can cause empty mail!

Note: This is not my work! I improved the available version for my own need, and for other users with a similar demand.

import subprocess
import time
import sys
import pexpect

asfdef remote(ip, username, password, script):
    print ("ssh " + username + "@" + ip)
    ssh_newkey = 'Are you sure you want to continue connecting'
    child = pexpect.spawn("ssh " + username + "@" + ip + " " + script)
    i = child.expect([pexpect.TIMEOUT, ssh_newkey, 'password'])
    if i == 0: # Timeout
        print 'ERROR!'
        print 'SSH could not login. Here is what SSH said:'
        print child.before, child.after
        return None
    if i == 1: # SSH does not have the public key. Just accept it.
        child.sendline ('yes')
        child.expect ('password: ')
        i = child.expect([pexpect.TIMEOUT, 'password: '])
        if i == 0: # Timeout
          print 'ERROR!'
          print 'SSH could not login. Here is what SSH said:'
          print child.before, child.after
        return None
    if i == 2:
        child.sendline(password)
        child.sendline("")
        return child
        
def generateScript(userList, loginPassword):
    script = ""
    with open(userList) as f:
        for line in f.readlines():
            words = line.split(" ")

            username = words[0];
            password = words[1].strip();
            script += "echo " + str(loginPassword) + "| sudo -S userdel " + username + ";"

    return script

if __name__ == "__main__":
    serverList = "/home/test/server.txt"
    userList = "/home/test/user.txt"
    with open(serverList) as f:
        for line in f.readlines():
            words = line.split(" ")

            ip = words[0];
            loginName = words[1];
            loginPassword = words[2].strip();
            script = generateScript(userList, loginPassword)
            remote(ip, loginName, loginPassword, script)

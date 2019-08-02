# sync perforce client to a specific change list

```
p4 sync @280
```
# view change list size:
```
p4 -u superAdmin -p 2346 sizes -sh //...@4515989,4515989
//...@4515989,4515989 5441 files 363G bytes
```
# view file list of a specific change list
```
p4 files @=3127533
p4 -Ztag -F "%depotFile%" files @=3127533
```

# list opened files by a specific client (workspace)
```
p4  opened -C  jpelletier2_FCC_data
```

# check what path a user subscribed to for commit change notifications:
```
/opt/perforce/bin/p4 -u superAdmin -p p4-code.example.org:1806 user -o iazmanov
```
# check which users are subscribed to a depot path for commit change notifications
```
[root@swarm04 ~]# /opt/perforce/bin/p4 -u superAdmin -p p4-code.example.org:1806 reviews //lty/dev/trunk/source/scimitar/graphic/...

iazmanov
johnstoneb

```
## To see which users are subscribed to files in a particular changelist
```
 p4 reviews -c <changelist>
```

# view which changelist changed a file
```
p4 -p 10.194.101.115:2326 verify //depot/file
```

# view a changelist
```bash
p4 -p 10.194.101.115:2326 change -o 1210981
```

# shelving and unshelving

Shelving enables you to store copies of open files temporarily in the shared Perforce repository without checking them in.

When you shelve a file, a copy is placed in a pending changelist from which other users can unshelve it.

# backup and restore (checkpoint and journal files)

A checkpoint is a snapshot or copy of the database at a particular moment in time.

A journal is a log of updates to the database since the last snapshot was taken.

you cannot restore any versioned files from a checkpoint.
You can, however, restore all changelists, labels, jobs, and so on, from a checkpoint.

To restore from a backup, the checkpoint must be at least as old as the files in the depots, that is,
the versioned files can be newer than the checkpoint, but not the other way around. As you might expect,
the shorter this time gap, the better.

The sequence numbers reflect the roll-forward nature of the journal. To restore databases to older checkpoints,
match the sequence numbers. That is, you can restore the state of Helix Server as it was when checkpoint.6 was
taken by restoring checkpoint.5 and then loading journal.5 which contains all the changes made between checkpoint.5 and checkpoint.6.
In most cases, you’re only interested in restoring the current database, which is reflected by the highest-numbered checkpoint.n
rolled forward with the changes in the current journal.

The journal is the running transaction log that keeps track of all database modifications since the last checkpoint.
It’s the bridge between two checkpoints.

## distributed deployments
Each edge server maintains a unique set of workspace and work-in-progress data that must be backed up separately from the commit server.
Exclusive locks are global: establishing an exclusive lock requires communication with the commit server, which might incur network latency.
Shelving changes in a distributed environment typically occurs on an edge server.
	Shelving can occur on a commit server only while using a client workspace bound to the commit server.
	Normally, changelists shelved on an edge server are not shared between edge servers.
	You can promote changelists shelved on an edge server to the commit server, making them available to other edge servers.
	See "Promoting shelved changelists" on the facing page for details.
Auto-creation of users is not possible on edge servers.

You must use a command like the following to delete a client that is bound to an edge server:
It is not sufficient to simply use the -d and -f options.
```bash
$ p4 client -d -f --serverid=thatserver thatclient
```
This prevents your inadvertently deleting a client from an edge server.
Likewise, you must specify the server id and the changelist number when trying to delete a changelist whose client is bound to an edge server.
```
$ p4 change -d -f --serverid=thatserver 6321
```

### rdb.lbr table, which records the archive data transferred from the master Helix Server to the replica.
To display the contents of this table when a replica is running, run:
```
$ p4 -p replica:22222 pull -l
```

Likewise, if you only need to know how many file transfers are active or pending, use
```
p4 -p replica:22222 pull -l -s.
```

If a specific file transfer is failing repeatedly (perhaps due to unrecoverable errors on the master),
you can cancel the pending transfer with
```
p4 pull -d -f file -r rev
# where file and rev refer to the file and revision number.
```

## Commit and edge servers must use the same time zone.

## list ldap config and test it
```
[hbcheng@perf06 rkb-1867]$ p4 -u superAdmin -p 10.0.14.139:1867 ldaps
ldap-emea ldap-emea.example.org:389 sasl (enabled)

[hbcheng@perf06 rkb-1867]$ p4 -u superAdmin -p 10.0.14.139:1867 ldap -t hbcheng ldap-emea
Enter password:
Authentication successful.
```
## check if a file is opened/locked somewhere
```
p4 -p p4p-hunter-sha.example.org:4723 opened -a //hunter/MAIN/data/hunter/baked/art/props/pr_sha_0023/pr_sha_0023_b.editordata                                     [1]
//hunter/MAIN/data/hunter/baked/art/props/pr_sha_0023/pr_sha_0023_b.editordata - file(s) not opened anywhere.

p4 -p p4p-hunter-sha.example.org:4723 opened -a //hunter/MAIN/data/hunter/metadata/002/pr_sha_0023_b.mmb.asset

//hunter/MAIN/data/hunter/metadata/002/pr_sha_0023_b.mmb.asset#2 - edit default change (binary+F) by dlma@dlm_AA060_Hrogue

```

## migrate client/workspace from one edge to another:
```
/opt/perforce/bin/2015.2/1377629/p4 -p destinationServer:port reload -f -c $clients -p sourceServer:port
```

## to get last submitted change list number
```
p4 changes -m 1 -s submitted

# The last changelist number successfully submitted (that is, no longer pending) to the Perforce service is held in the maxCommitChange counter.

p4 counter change
# The last changelist number known to the Perforce service includes pending changelists created by users, but not yet submitted to the depot.
```

## list swarm UrlOfSwarmHost
```
p4 -p p4-fc3-data.example.org:2346 property -l -n P4.Swarm.URL
```

## workspace migration

 /opt/perforce/bin/2015.2/1377629/p4 -p destinationServer:port reload -f -c $clients -p sourceServer:port


## list shelved changes
```bash
p4 changes -u <USERNAME> -s shelved
```

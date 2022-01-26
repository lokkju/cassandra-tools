# Cassandra Tools
*Simple tools for with minimal requirements, for making Cassandra tasks easier*

Base requirements usually include `bash`, a recent version of `GNU Parallel` and a local install of Cassandra

If your `PATH` doesn't include both `cassandra/bin` and `cassandra/tools/bin`,
either set your `PATH` or set `CASSANDRA_HOME`

- **ls-sstm** : display the min and max dates for each SSTable in a directory

## Tools
### ls-sstm
*display the min and max dates for each SSTable in a directory*

When using Cassandra's *Time Window Compaction Strategy*, SSTables do not get
deleted if they contain any rows with a TTL set to 0. If you didn't set a TTL
on insert, and didn't set a default TTL for the table, your SSTables will never
get automatically deleted.

This script allows you to easily see the date range each SSTables covers, so
you can select which table to drop. It utilizes `GNU Parallel` and
`sstablemetadata` to extract the information for each SSTable, and displayed
the SSTables sorted by the max date, descending.

#### Usage
Fetch the script:
```
wget -q https://github.com/lokkju/cassandra-tools/raw/main/ls-sstm.sh
chmod +x ls-sstm.sh
```

Run the script:
```
ls-sstm.sh /usr/local/cassandra/data/keyspace/table-random/
```

Output:
```
Attempting to read SSTables from /usr/local/cassandra/data/keyspace/table-ebd3aa8090b411e79a9a15d188412509
Scanning 130 SSTables
100% 130:0=0s /usr/local/cassandra/data/keyspace/table-ebd3aa8090b411e79a9a15d188412509/mc-395737-big-Data.db                                                                                             
  Max Date   Min Date Droppable     Size   Modified Filename
2017-09-05 2017-09-03      0.00      14G 2021-04-05 /usr/local/cassandra/data/keyspace/table-ebd3aa8090b411e79a9a15d188412509/mc-209270-big-Data.db
2017-09-09 2017-09-06      0.31     314M 2021-04-05 /usr/local/cassandra/data/keyspace/table-ebd3aa8090b411e79a9a15d188412509/mc-209269-big-Data.db
2017-10-08 2017-10-07      0.32     3.5G 2021-04-05 /usr/local/cassandra/data/keyspace/table-ebd3aa8090b411e79a9a15d188412509/mc-209268-big-Data.db
```

## GNU Parallel
If your system does not have a recent version of `GNU Parallel`, you can find
packages for most distributions at https://software.opensuse.org//download.html?project=home%3Atange&package=parallel

For Amazon Linux 2 (amzn2), the following is known to work:
```
wget https://download.opensuse.org/repositories/home:/tange/PowerKVM_3.1/noarch/parallel-20220122-1.1.noarch.rpm
sudo yum install ./parallel-20220122-1.1.noarch.rpm
```

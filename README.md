# charlie-topsy-stats
Statistical analysis, via topsy.com API, of tweets mentioning #CharlieHebdo with lexical references to terrorism after Januray 2015 Paris shootings

* topsy_stats.pl : Perl script that fetchs tweets with topsy.com API, filtered with #CharlieHebdo hashtag, in a given time range, deletes duplicates, counts total number of tweets, counts tweets including keywords related to terrorism, and outputs in CSV (comma separated values) format
* topsy_stats_attentat.csv : CSV output file for time range 2015-01-07 11:30:00 to 2015-01-07 14:59:59
* topsy_stats.ods : LibreOffice Calc import of CVS output, with some graphs manually created
* topsy_stats.png : graph with all #CharlieHebdo tweets and tweets related to terrorsim, exported from LibreOffice Calc
* topsy_stats_terrorisme.png : graph with #CharlieHebdo tweets related to terrorsim, exported from LibreOffice Calc

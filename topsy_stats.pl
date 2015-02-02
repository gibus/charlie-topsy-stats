#! /usr/bin/perl

use strict;
use warnings;

use LWP::UserAgent;
use DateTime;
use JSON;
use Data::Dumper;
use Encode;

# Parameters
my $start_time = DateTime->new(
  time_zone => 'Europe/Paris',
  year      => 2015,
  month     => 1,
  day       => 7,
  hour      => 11,
  minute    => 30,
  second    => 00,
);
my $end_time = DateTime->new(
  time_zone => 'Europe/Paris',
  year      => 2015,
  month     => 1,
  day       => 7,
  hour      => 14,
  minute    => 54,
  second    => 59,
);
my $time_interval = DateTime::Duration->new(
  minutes   => 4,
  seconds   => 59,
);
my $time_increment = DateTime::Duration->new(
  minutes   => 5,
);

my $sample_url= 'http://api.topsy.com/v2/content/tweets.json?apikey=09C43A9B270A470B8EB8F2946A9369F3&q=%23CharlieHebdo&sort_by=-date&mintime=1420630090&maxtime=1420630099&limit=500';
my $base_url = 'http://api.topsy.com/v2/content/tweets.json';
my $api_key = '09C43A9B270A470B8EB8F2946A9369F3';
my $query = '%23CharlieHebdo';
my $sort = '-date';
my $limit = 500;

my @search_words = ('terroris', 'terreur', 'peur', 'attentat');
our %seens;
my @results;

our $ua = LWP::UserAgent->new(env_proxy => 1);

# Fetch tweets including #CharlieHebdo
sub process_url($) {
  my $url = shift;
  my $res = $ua->get($url);

  unless ($res->is_success or $res->is_redirect) {
    die "Error in fetch request '$url': !" . $res->message . "! code=!" . $res->code . "!\n";
  }

  my $total_tweets = 0;
  my $matched_tweets = 0;

  # Parse response
  my $res_obj = decode_json($res->content);

  my $tweets = $res_obj->{response}{results}{list};
  
  # Parse tweets
  foreach my $tweet (@$tweets) {
    my $tweet_url = $tweet->{url};
    unless (exists($seens{$tweet_url})) {
      $seens{$tweet_url} = 1;
      $total_tweets++;
      my $text = encode_utf8($tweet->{tweet}->{text});
      foreach my $word (@search_words) {
        if ($text =~ /$word/i) {
          $matched_tweets++;
          last;
        }
      }
    }
  }
  my $more_results = $res_obj->{response}{results}{more_results};
  my $last_offset = $res_obj->{response}{results}{last_offset};

  return($total_tweets, $matched_tweets, $more_results, $last_offset);
}
 
# Loop through all intervals
for (my $min_time = $start_time; $min_time < $end_time; $min_time += $time_increment) {
  my $max_time = $min_time + $time_interval;
  my $url = $base_url . "?apikey=$api_key&q=$query&sort_by=$sort&mintime=" . $min_time->epoch . "&maxtime=" . $max_time->epoch . "&limit=$limit";
  warn "Processing " . $min_time->hms . "-" . $max_time->hms . "\n";
  my ($total_tweets, $matched_tweets, $more_results, $last_offset) = process_url($url);

  # Process remaining requests
  while ($more_results) {
    my $next_url = $base_url . "?apikey=$api_key&q=$query&sort_by=$sort&mintime=" . $min_time->epoch . "&maxtime=" . $max_time->epoch . "&limit=$limit&offset=$last_offset";
    warn "Processing offset $last_offset " . $min_time->hms . "-" . $max_time->hms . "\n";
    my ($next_total_tweets, $next_matched_tweets, $next_more_results, $next_last_offset) = process_url($next_url);
    $total_tweets += $next_total_tweets;
    $matched_tweets += $next_matched_tweets;
    $more_results = $next_more_results;
    $last_offset = $next_last_offset;
  }

  # Save this interval results
  my $interval_result = [$min_time->strftime('%H:%M'), $max_time->strftime('%H:%M'), $total_tweets, $matched_tweets];
  push @results, $interval_result;
  my $next_time = $min_time + $time_increment;
}

# Print results
print "\"Heure début\", \"Heure fin\", \"Nombre total de tweets #CharlieHebdo\", \"Nombre de tweets sur le terrorisme\"\n";
foreach my $line (@results) {
  print $line->[0] . ',' . $line->[1] . ',' . $line->[2] . ',' . $line->[3]. "\n";
}

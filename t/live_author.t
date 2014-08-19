#!/usr/bin/perl -w
use strict;
use warnings;
use Test::More;
use WebService::JotForm;
use JSON::Any;
use Data::Dumper;

#Test some of the api methods, before allowing a release to happen

if (not $ENV{RELEASE_TESTING} ) {
    plan skip_all => 'Set $ENV{RELEASE_TESTING} to run release tests.'
}

my $token_file = "$ENV{HOME}/.webservice-jotform.token";
my $token;

eval {
    open(my $fh, '<', $token_file);
    chomp($token = <$fh>);
};

if (not $token) {
    plan skip_all => "Cannot read $token_file";
}

my $jotform = WebService::JotForm->new(apiKey => $token);


my $user_info = $jotform->get_user();

ok(exists $user_info->{'limit-left'}, "Got a limit-left key in return for get_user");

my $user_usage = $jotform->get_user_usage();

ok(exists $user_usage->{content}{submissions}, "Got a submissions key in return for get_user_usage");

my $user_submissions = $jotform->get_user_submissions();
ok(exists $user_submissions->{content}[0]{form_id}, "Got a form_id key in return for get_user_submissions");

my $forms = $jotform->get_user_forms();

my $formid = $forms->{content}[0]{id};

ok($formid, "Got at least one form as well as an id for it");

my $form_submissions_info = $jotform->get_form_submissions($formid);

ok(exists $form_submissions_info->{resultSet}, "Got a resultSet back");
ok($form_submissions_info->{resultSet}{count} >0, "Got a resultSet back with at least one form submission");


done_testing;

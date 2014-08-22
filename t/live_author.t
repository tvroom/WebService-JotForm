#!/usr/bin/perl -w
use strict;
use warnings;
use Test::More;
use WebService::JotForm;
use JSON::Any;
use Data::Dumper;
use Test::Deep;

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

my $cases = {
	'response_wrap' => {
          'responseCode' => 200,
          'limit-left' => re('^\d+$'), 
          'message' => 'success'
        },
	get_user_content => {
		username => re('^\w+$')
	},
	get_user_usage_content => {
		submissions => re('^\d+$'),
		payments => re('^\d+$'),
		submissions => re('^\d+$'),
		ssl_submissions => re('^\d+$'),
		uploads => re('^\d+$'),
	}
	

};

my $jotform = WebService::JotForm->new(apiKey => $token);


my $user_info = $jotform->get_user();

cmp_deeply($user_info, superhashof($cases->{response_wrap}), "Got expected result from get_user() response_wrap");
cmp_deeply($user_info->{content}, superhashof($cases->{get_user_content}), "Got expected result from get_user() call for content returned");

my $user_usage = $jotform->get_user_usage();
cmp_deeply($user_usage, superhashof($cases->{response_wrap}), "Got expected result from get_user_usage() response_wrap");
cmp_deeply($user_usage->{content}, superhashof($cases->{get_user_usage_content}), "Got expected result from get_user_usage() content");

ok(exists $user_usage->{content}{submissions}, "Got a submissions key in return for get_user_usage");

my $user_submissions = $jotform->get_user_submissions();
cmp_deeply($user_submissions, superhashof($cases->{response_wrap}), "Got expected result from get_user_submissions() response_wrap");

print Dumper($user_submissions);
ok(exists $user_submissions->{content}[0]{form_id}, "Got a form_id key in return for get_user_submissions");

my $forms = $jotform->get_user_forms();

my $formid = $forms->{content}[0]{id};

ok($formid, "Got at least one form as well as an id for it");

my $form_submissions_info = $jotform->get_form_submissions($formid);

ok(exists $form_submissions_info->{resultSet}, "Got a resultSet back");
ok($form_submissions_info->{resultSet}{count} >0, "Got a resultSet back with at least one form submission");


done_testing;

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
	
	resultSet => {
		'count'  => re('^\d+$'), 
		'limit'  => re('^\d+$'),
		'offset' => re('^\d+$'),
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
	},

	get_user_folders_content => {
                         'owner' => re('^[A-Za-z0-9]+$'),
                         'path' =>  re('^[A-Za-z0-9]+$'),
                         'id' =>    re('^[A-Za-z0-9]+$'),
	},

        get_user_reports_content_first => {
                           'form_id' => re('^[0-9]+$'),
                           'id' => re('^[0-9]+$'),
                           'list_type' => re('^[a-zA-Z0-9]+$')
        },
	get_form_content => {
                         'count' => re('^[0-9]+$'),
                         'id' => re('^[0-9]+$'),
                         'new' => re('^[0-9]+$'),
        },
	get_form_question_content => {
                         'qid' => re('^[0-9]+$'),
                         'type' => re('^[A-Za-z0-9_]+$')
                       },
	get_form_reports_content_first => {
                           'form_id' => re('^[0-9]+$'),
                           'list_type' =>  re('^[a-zA-Z0-9]+$'),
                           'url' => re('^http:'),
                       },
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
cmp_deeply($user_submissions->{resultSet}, superhashof($cases->{resultSet}), "Got expected result from get_user_submissions() resultSet block");

ok(exists $user_submissions->{content}[0]{form_id}, "Got a form_id key in return for get_user_submissions");

my $forms = $jotform->get_user_forms();
cmp_deeply($forms, superhashof($cases->{response_wrap}), "Got expected result from get_user_form() response_wrap");

my $formid = $forms->{content}[0]{id};

ok($formid, "Got at least one form as well as an id for it");

my $form_submissions_info = $jotform->get_form_submissions($formid);
cmp_deeply($form_submissions_info, superhashof($cases->{response_wrap}), "Got expected result from get_form_submissions() response_wrap");
cmp_deeply($form_submissions_info->{resultSet}, superhashof($cases->{resultSet}), "Got expected result from get_form_submissions() resultSet");

ok($form_submissions_info->{resultSet}{count} >0, "Got a resultSet back with at least one form submission");

my $sub_users = $jotform->get_user_subusers();
cmp_deeply($sub_users, superhashof($cases->{response_wrap}), "Got expected results from get_user_subusers() response_wrap");

my $folders = $jotform->get_user_folders();
cmp_deeply($folders, superhashof($cases->{response_wrap}), "Got expected results from get_user_folders() response_wrap");
cmp_deeply($folders->{content}, superhashof($cases->{get_user_folders_content}), "Got expected results from get_user_folders() content");

my $reports = $jotform->get_user_reports();
cmp_deeply($reports, superhashof($cases->{response_wrap}), "Got expected results from get_user_reports() response_wrap");
cmp_deeply($reports->{content}[0], superhashof($cases->{get_user_reports_content_first}), "Got expected results from get_user_reports() content first");

my $settings = $jotform->get_user_settings();
cmp_deeply($settings, superhashof($cases->{response_wrap}), "Got expected results from get_user_settings() response_wrap");

my $history = $jotform->get_user_history();
cmp_deeply($settings, superhashof($cases->{response_wrap}), "Got expected results from get_user_history() response_wrap");

my $form = $jotform->get_form($formid);
cmp_deeply($form, superhashof($cases->{response_wrap}), "Got expected results from get_form() response_wrap");
cmp_deeply($form->{content}, superhashof($cases->{get_form_content}), "Got expected results from get_form() content");

my $questions = $jotform->get_form_questions($formid);
cmp_deeply($questions, superhashof($cases->{response_wrap}), "Got expected results from get_form_questions() response_wrap");
ok(exists $questions->{content}{1}{name}, "Got a name for a first question for get_form_questions");
ok(exists $questions->{content}{1}{type}, "Got a type for a first question for get_form_questions");

my $question = $jotform->get_form_question($formid, 1);
cmp_deeply($question, superhashof($cases->{response_wrap}), "Got expected results from get_form_question() response_wrap");
cmp_deeply($question->{content}, superhashof($cases->{get_form_question_content}), "Got expected results from get_form_question() content");

my $form_properties = $jotform->get_form_properties($formid);
cmp_deeply($form_properties, superhashof($cases->{response_wrap}), "Got expected results from get_form_properties() response_wrap");

my $form_reports = $jotform->get_form_reports($formid);
cmp_deeply($form_reports, superhashof($cases->{response_wrap}), "Got expected results from get_form_reports() response_wrap");
cmp_deeply($form_reports->{content}[0], superhashof($cases->{get_form_reports_content_first}), "Got expected results from get_form_reports() content first");

my $form_files = $jotform->get_form_files($formid);
cmp_deeply($form_files, superhashof($cases->{response_wrap}), "Got expected results from get_form_files() response_wrap");

my $form_webhooks = $jotform->get_form_webhooks($formid);
cmp_deeply($form_webhooks, superhashof($cases->{response_wrap}), "Got expected results from get_form_webhooks() response_wrap");
done_testing;

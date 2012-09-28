use strict;
use Test::More; 
### database tests
chdir($ENV{TMP} || $ENV{TMPDIR} || "/tmp");
unlink('db.json');


use_ok( 'DBLock');
use DBLock;

use MyDB;
use_ok( 'MyDB' );

my $data = MyDB::readDB();
ok($data);
$data->{__test__} = "".rand();
MyDB::writeDB($data);
my $newdata = MyDB::readDB();
ok($data->{__test__} eq $newdata->{__test__});
my $newval = "".rand();
MyDB::readWriteDB( sub {
	my ($data) = @_;
	$data->{_readWriteDB_test_} = $newval;
	return (1,$data);
});
$newdata = MyDB::readDB();
ok($newdata->{_readWriteDB_test_} eq $newval);
MyDB::readWriteDB( sub {
	my ($data) = @_;
	delete $data->{_readWriteDB_test_};
	return (1,$data);
});
$newdata = MyDB::readDB();
ok(! exists $newdata->{_readWriteDB_test_});

use_ok('Database');
use Database;
my $database = Database->new();

my @tasks = $database->get_tasks();
ok(@tasks == 0);

use_ok('Task');
use Task;
my @tasks = map {
	$database->insert_task( Task->new( summary => "Test $_", description => "Desc of Test $_" ) );
} (1..10);
foreach my $task (@tasks) {
	ok($task->id,"tasks id");
	my $newtask = $database->get_single_task( $task->id);
	ok($newtask->equals($task),"task equals");
}
my @tasks = $database->get_tasks();
ok(@tasks == 10, "Get tasks");
my ($task) = $database->get_last_tasks(1);
ok($tasks[$#tasks]->id eq $task->id, "last task equal last task ");
use_ok('TaskLite');
my @summaries1 = map { $_->summary } $database->get_task_summaries();
my @summaries2 = map { $_->summary } @tasks;
ok(join("\n", @summaries1) eq join("\n", @summaries2), "Summaries are the same");

# test if we can save hashes and stuff
my $task = Task->new(content=>{a=>'b','c'=>[1,2,3]});
$database->insert_task( $task );
my $newtask = $database->get_single_task( $task->id );
ok($newtask->content()->{a} eq 'b');
ok($newtask->content()->{c}->[1] == 2);

# command factory tests
use_ok('CommandFactory');

END {
	done_testing();
}

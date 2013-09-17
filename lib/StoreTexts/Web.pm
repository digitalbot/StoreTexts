package StoreTexts::Web;

use strict;
use warnings;
use utf8;
use Kossy;
use DBIx::Sunny;
use Digest::SHA;

sub dbh {
    my $self = shift;
    my $db = $self->root_dir .'/store_texts.db';
    $self->{_dbh} ||= DBIx::Sunny->connect("dbi:SQLite:dbname=$db", '', '', {
        Callbacks => {
            connected => sub {
                my $conn = shift;
                $conn->do(<<EOF);
CREATE TABLE IF NOT EXISTS entry (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    object_id VARCHAR(255) NOT NULL UNIQUE,
    nickname VARCHAR(255) NOT NULL,
    body TEXT,
    extra VARCHAR(255),
    created_at DATETIME NOT NULL
);
EOF
                $conn->do(q{CREATE INDEX IF NOT EXISTS index_created_at ON entry ( created_at )});
                return;
            },
        },
    });
}

sub add_entry {
    my $self = shift;
    my ($body, $nickname) = @_;
    $body //= '';
    $nickname //= 'anonymous';
    my $object_id = substr(Digest::SHA::sha1_hex($$ . join("\0", @_) . rand(1000) ), 0, 16);
    $self->dbh->query(
        q{INSERT INTO entry (object_id, nickname, body, created_at) VALUES ( ?, ?, ?, DATETIME('now') )},
        $object_id, $nickname, $body
    );
    return $object_id;
}

sub entry_list {
    my $self = shift;
    my $offset = shift;
    $offset //= 0;
    my $rows = $self->dbh->select_all(
        q{SELECT * FROM entry ORDER BY created_at DESC LIMIT ?,11},
        $offset
    );
    my $next;
    $next = pop @$rows if @$rows > 10;
    return $rows, $next;
}

get '/' =>  sub {
    my ($self, $c)  = @_;
    my $result = $c->req->validator([
        'offset' => {
            default => 0,
            rule => [
                ['UINT','ivalid offset value'],
            ],
        },
    ]);
    $c->halt(403) if $result->has_error;
    my ($entries, $has_next) = $self->entry_list($result->valid('offset'));
    $c->render('index.tx', {
        offset => $result->valid('offset'),
        entries => $entries,
        has_next => $has_next,
    });
};

post '/create' => sub {
    my ($self, $c) = @_;
    my $result = $c->req->validator([
        'body' => {
            rule => [
                ['NOT_NULL','empty body'],
            ],
        },
        'nickname' => {
            default => 'anonymous',
            rule => [
                ['NOT_NULL','empty nickname'],
            ],
        }
    ]);
    if ($result->has_error) {
        return $c->render('index.tx', { error => 1, messages => $result->errors });
    }
    my $object_id = $self->add_entry(map {$result->valid($_)} qw/body nickname/);
    return $c->redirect('/');
};

1;

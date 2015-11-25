package Core::Control;
use Template;
use Scalar::Util qw(blessed);

sub new {
    my $class = shift;

    # Initialize with default values
    my $self = {
        'status-code' => 200,
        'content-type' => 'text/html',
        'html' => '',
    };
    bless $self, $class;

    return $self;
}

sub run {
    my ($self, $r) = @_;

    unless (blessed($self) && $self->can("handler")) {
        die("Handler function isn't exist");
    }

    my $http_status = eval { $self->handler($r) };

    if (my $error = $@ || !$http_status) {
        my $error_msg = ( $error ) ? $error : 'Eval failed, but $@ is empty.';
        print STDERR "[ERROR] $error_msg\n";

        return [
            500,
            [ 'Content-Type' => 'text/html' ],
            [ 'html' => 'Internal Server Error' ],
        ];
    }

    $self->__set_status_code( $http_status );

    return [
        $self->__get_status_code(),
        [ 'Content-Type' => $self->__get_content_type() ],
        [ $self->__get_html() ],
    ];
}

sub process_template {
    my ($self, %args) = @_;

    die("What is template file name?") unless $args{template};

    my $buffer = '';
    my $template = Template->new(
        INCLUDE_PATH => './www/styles/draft/',
        OUTPUT_PATH  => './cache',
    );

    $template->process(
        $args{template}, $args{data}, \$buffer ) || die $template->error();

    $self->__set_html($buffer);
}

sub __get_status_code {
    my $self = shift;
    return $self->{'status-code'};
}

sub __set_status_code {
    my ($self, $code) = @_;
    $self->{'status-code'} = $code;
}

sub __get_content_type {
    my $self = shift;
    return $self->{'content-type'};
}

sub __set_content_type {
    my ($self, $ctype) = @_;
    $self->{'content-type'} = $ctype;
}

sub __get_html {
    my $self = shift;
    return $self->{html};
}

sub __set_html {
    my ($self, $html) = @_;
    $self->{html} = $html;
}

1;

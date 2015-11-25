package App::Control::Home;

use base ( "App::Control" );

sub handler {
    my ($self, $r) = @_;

    $self->process_template(
        template => 'home_page.tt',
        data => {
            title   => "Main page",
            message => "Index page",
        }
    );

    return 200;
}

1;

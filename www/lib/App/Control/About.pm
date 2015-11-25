package App::Control::About;

use base ( "App::Control" );

sub handler {
    my ($self, $r) = @_;

    $self->process_template(
        template => 'about_page.tt',
        data => {
            title   => "About Us",
            message => "About Text...",
        }
    );

    return 200;
}

1;

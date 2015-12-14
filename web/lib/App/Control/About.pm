package App::Control::About;

use base ( "App::Control" );

sub handler {
    my ($self, $r) = @_;

    $self->render(
        template => 'about_page.tt',
        data => {
            title   => "About Us",
            message => "About Text...",
        }
    );

    return 200;
}

1;

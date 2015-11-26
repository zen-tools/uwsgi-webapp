package App::Control::Contact;

use base ( "App::Control" );

sub handler {
    my ($self, $r) = @_;

    $self->process_template(
        template => 'contact_page.tt',
        data => {
            title   => "Contact",
            message => "Contact page",
        }
    );

    return 200;
}

1;

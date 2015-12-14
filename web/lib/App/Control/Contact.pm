package App::Control::Contact;

use base ( "App::Control" );

sub handler {
    my ($self, $r) = @_;

    my $message = "Contact page";
    if ($r->method() == 'POST') {
        $message = "Thanks for your message!";
    }


    $self->render(
        template => 'contact_page.tt',
        data => {
            title   => "Contact",
            message => "$message",
        }
    );

    return 200;
}

1;

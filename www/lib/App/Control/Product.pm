package App::Control::Product;

use base ( "App::Control" );

sub handler {
    my ($self, $r) = @_;

    $self->process_template(
        template => 'product_page.tt',
        data => {
            title   => "Our product",
            message => "Text...",
        }
    );

    return 200;
}

1;

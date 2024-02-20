package CustomizableListDateFormat::Plugin;

use strict;
use warnings;
use MT::Util qw( format_ts );

sub plugin {
    return MT->component('CustomizableListDateFormat');
}

sub hdlr_date_format {
    my ($prop, $obj) = @_;

    my $plugin = plugin();
    my $blog = MT->app->blog || undef;
    my $user = MT->app->user;
    my $user_lang = $user ? $user->preferred_language: undef;

    my $object_type = $prop->{object_type};
    my $col = $prop->{col};
    my $ts = $obj->$col;

    my $setting_name = "setting_${object_type}_${col}";
    my $setting_value = $plugin->get_config_value($setting_name, 'system') || undef;

    my $out = format_ts($setting_value, $ts, $blog, $user_lang);

    return $out;
}

sub hdlr_content_data_list_properties {
    my $order = 1000;
    return +{
        authored_on => {
            auto    => 1,
            display => 'default',
            label   => sub {
                MT->translate('Publish Date');
            },
            use_future => 1,
            order      => $order + 100,
            sort       => sub {
                my $prop = shift;
                my ( $terms, $args ) = @_;
                my $dir = delete $args->{direction};
                $dir = ( 'descend' eq $dir ) ? "DESC" : "ASC";
                $args->{sort} = [
                    { column => $prop->col, desc => $dir },
                    { column => "id",       desc => $dir },
                ];
                return;
            },
            html => \&hdlr_date_format,
        },
        created_on => {
            base  => '__virtual.created_on',
            label   => sub {
                MT->translate('Created On');
            },
            order => $order + 200,
            display => 'optional',
            html => \&hdlr_date_format,
        },
        modified_on => {
            base  => '__virtual.modified_on',
            order => $order + 300,
            display => 'default',
            label   => sub {
                MT->translate('Date Modified');
            },
            html => \&hdlr_date_format,
        },
        unpublished_on => {
            auto    => 1,
            display => 'optional',
            label   => sub {
                MT->translate('Unpublish Date');
            },
            order => $order + 400,
            html => \&hdlr_date_format,
        },
    };

}

1;

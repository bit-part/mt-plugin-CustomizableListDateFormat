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

1;

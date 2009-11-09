use Purple;
use Net::PingFM;
our $old_messageb="";
%PLUGIN_INFO = (
    perl_api_version => 2,
    name => "Status to Ping.FM",
    version => "0.01",
    summary => "Update Ping.FM with your pidgin status",
    description => "Your Ping.FM status will be updated to reflect the status set in a configured IM account using Pidgin. This product uses the Ping.fm API but is not endorsed or certified by Ping.fm.",
    author => "Herb Riede <support\@rabidnerd.com> (based heavily on Status to Twitter by Ethan Goldblum <egoldblum\@cmu.edu>)",
    url => "http://www.rabidnerd.com",
    load => "plugin_load",
    unload => "plugin_unload",
    prefs_info => "prefs_info_rnp"
);

sub plugin_init {
    return %PLUGIN_INFO;
}

sub plugin_load {
    my $plugin = shift;
    Purple::Prefs::add_none("/plugins/core/status_to_pingfm");
    Purple::Prefs::add_string("/plugins/core/status_to_pingfm/pinguserkey", "");
    $status_handle = Purple::SavedStatuses::get_handle();
    Purple::Signal::connect($status_handle, "savedstatus-changed", $plugin, \&status_changed_rnp, undef);
}

sub plugin_unload {
    my $plugin = shift;
}

sub prefs_info_rnp {
    $frame = Purple::PluginPref::Frame->new();
    $ppref = Purple::PluginPref->new_with_name_and_label("/plugins/core/status_to_pingfm/pinguserkey", "Ping.fm Application Key - http://ping.fm/key");
    $ppref->set_type(2);
    $ppref->set_max_length(155);
    $frame->add($ppref);
    return $frame;
}

sub status_changed_rnp {
   my $username = Purple::Prefs::get_string("/plugins/core/status_to_pingfm/pinguserkey");
	# Make pingfm object with our user and api keys:
 my $pfm = Net::PingFM->new( user_key => $username,
                            api_key => 'ce0efe65c5b2794d148a70e18d12061f' );
 # check they like our keys (you don't need to do this!)
 if($pfm->user_validate) {
    my ($new, $old) = @_;
    my $old_message = Purple::SavedStatus::get_message($old);
    my $new_message = Purple::SavedStatus::get_message($new);
  #Purple::Notify::message($plugin, 2, "Message Change Debug 2", "Here are the different messages:", $old_message."\n".$new_message."\n".$old_messageb, NULL, NULL);
    Purple::Debug::info("status_to_pingfm", "Status changed from " . $old_message . " to " . $new_message . "\n");
	if($old_message == $new_message) {
	if($old_messageb ne "") {
	$old_message = $old_messageb;
	}
	}
    $old_messageb =  $new_message;
#Purple::Notify::message($plugin, 2, "Message Change Debug 2", "Here are the different messages:", $old_message."\n".$new_message."\n".$old_messageb, NULL, NULL);
	    if ($old_message ne $new_message) {
  # make a STATUS post:
    #Purple::Notify::message($plugin, 2, "WOULD POST", "To Ping.FM:", $new_message, NULL, NULL);
	$pfm->post( $new_message , { method => 'status' } );
     }
}
}




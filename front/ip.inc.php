<?

// ===================================================
// Copied from phpMyAdmin, unit ip_allow_deny.lib.php 
// http://www.phpmyadmin.net/
// ===================================================

/**
 * Gets the "true" IP address of the current user
 *
 * @return  string   the ip of the user
 *
 * @access  private
 */
function PMA_getIp()
{
    /* Get the address of user */
    if (!empty($_SERVER['REMOTE_ADDR'])) {
        $direct_ip = $_SERVER['REMOTE_ADDR'];
    } else {
        /* We do not know remote IP */
        return false;
    }

    /* Do we trust this IP as a proxy? If yes we will use it's header. */
    if (isset($GLOBALS['cfg']['TrustedProxies'][$direct_ip])) {
        $trusted_header_value = PMA_getenv($GLOBALS['cfg']['TrustedProxies'][$direct_ip]);
        $matches = array();
        // the $ checks that the header contains only one IP address, ?: makes sure the () don't capture
        $is_ip = preg_match('|^(?:[0-9]{1,3}\.){3,3}[0-9]{1,3}$|', $trusted_header_value, $matches);
        if ($is_ip && (count($matches) == 1)) {
            // True IP behind a proxy
            return $matches[0];
        }
    }

    /* Return true IP */
    return $direct_ip;
} // end of the 'PMA_getIp()' function 
?>
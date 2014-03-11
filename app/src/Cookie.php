<?php
namespace Pikd;

class Cookie {

    const EXPIRE = 'Mon, 01-Jan-1990 00:00:00 GMT';

    /** @var string */
    public $name;

    /** @var string */
    public $value;

    /** @var int */
    public $expire;

    /** @var string */
    public $path;

    /** @var bool */
    public $secure;

    /** @var bool */
    public $http_only;

    /** @var bool */
    public $deleted;

    /** @var array */
    public $headers;

    /** @var string */
    public $domain;

    /**
     * @param string $name
     * @param string $value
     * @param int $expire
     * @param bool $secure
     * @param bool $http_only
     */
    public function __construct($name, $value = "", $expire = 0, $secure = false, $http_only = false) {
        $this->name = $name;
        $this->value = $value;
        $this->expire = $expire;
        $this->secure = $secure;
        $this->http_only = $http_only;

        $this->path = '/';
        $this->deleted = false;
        $this->headers = array();

        $this->domain = Config::get('cookie_domain');;
    }

    /**
     * @return bool
     */
    public function set() {
        return setcookie(
                    $this->name, $this->value, $this->expire,
                    $this->path, $this->domain, $this->secure, $this->http_only
        );
    }

    /**
     * See the commentary in: http://us3.php.net/set_cookie and bug #8242.
     * PHP has an underdocumented "feature" that overrides the other parameters if
     * the value is set to an empty string and sends the client the word "deleted"
     * with an expiration time in one year in the past. A small but significant
     * percentage of our users have local dates that are incorrect by more than
     * one year.
     *
     * @param bool $send_headers
     */
    public function delete($send_headers = true) {
        $this->deleted = true;

        $h = "Set-Cookie: {$this->name}=; path={$this->path}; expires=" . self::EXPIRE;
        $this->headers[] = "$h; domain={$this->domain}";

        if ($send_headers) {
            $this->sendHeaders();
        }
    }

    private function sendHeaders() {
        foreach ((array)$this->headers as $header) {
            header($header, false);
        }
    }

    public static function setCookie($name, $value, $expire = null) {
        $cookie = new Cookie($name, $value, $expire);
        $cookie->set();
    }

    public static function deleteCookie($name) {
        $cookie = new Cookie($name);
        $cookie->delete();
    }
}

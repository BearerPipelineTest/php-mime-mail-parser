# php-mime-mail-parser

A fully tested email parser for PHP 7.3+ ([mailparse extension](https://www.php.net/manual/book.mailparse.php) wrapper).

It's the most effective php email parser around in terms of performance, foreign character encoding, attachment handling, and ease of use.
Internet Message Format RFC [822](https://tools.ietf.org/html/rfc822), [2822](https://tools.ietf.org/html/rfc2822), [5322](https://tools.ietf.org/html/rfc5322).

[![Latest Version](https://img.shields.io/packagist/v/php-mime-mail-parser/php-mime-mail-parser.svg?style=flat-square)](https://github.com/php-mime-mail-parser/php-mime-mail-parser/releases)
[![Total Downloads](https://img.shields.io/packagist/dt/php-mime-mail-parser/php-mime-mail-parser.svg?style=flat-square)](https://packagist.org/packages/php-mime-mail-parser/php-mime-mail-parser)
[![Software License](https://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat-square)](LICENSE)

## Why?

This extension can be used to...
 * Parse and read email from Postfix
 * For reading messages (Filename extension: eml)
 * Create webmail 
 * Store email information such a subject, HTML body, attachments, and etc. into a database

## Is it reliable?

Yes. All known issues have been reproduced, fixed and tested.

We use GitHub Actions, Codecov, Codacy to help ensure code quality. You can see real-time statistics below:

![Build Status](https://github.com/php-mime-mail-parser/php-mime-mail-parser/workflows/CI/badge.svg?branch=master&event=push)
[![Coverage](https://img.shields.io/codecov/c/gh/php-mime-mail-parser/php-mime-mail-parser?style=flat-square)](https://codecov.io/gh/php-mime-mail-parser/php-mime-mail-parser)
[![Code Quality](https://img.shields.io/codacy/grade/4e0e44fee21147ddbdd18ff976251875?style=flat-square)](https://app.codacy.com/app/php-mime-mail-parser/php-mime-mail-parser)


## How do I install it?

The easiest way is via [Composer](https://getcomposer.org/).

To install the latest version of PHP MIME Mail Parser, run the command below:

	composer require php-mime-mail-parser/php-mime-mail-parser

## Requirements

The following versions of PHP are supported:

* PHP 7.3
* PHP 7.4

Previous Versions:

| PHP Compatibility  | Version |
| ------------- | ------------- |
| HHVM  | php-mime-mail-parser 2.11.1    |
| PHP 5.4  | php-mime-mail-parser 2.11.1 |
| PHP 5.5  | php-mime-mail-parser 2.11.1 |
| PHP 5.6  | php-mime-mail-parser 3.0.4  |
| PHP 7.0  | php-mime-mail-parser 3.0.4  |
| PHP 7.1  | php-mime-mail-parser 5.0.5  |
| PHP 7.2  | php-mime-mail-parser 6.0.0  |

Make sure you have the mailparse extension (http://php.net/manual/en/book.mailparse.php) properly installed. The command line `php -m | grep mailparse` needs to return "mailparse".


### Install mailparse extension

#### Ubuntu, Debian & derivatives
```
sudo apt install php-cli php-mailparse
```

#### Php docker image

```
# Example with an alpine distribution
RUN apk update && apk add g++ autoconf make re2c && \
    pecl install mailparse && \
    docker-php-ext-enable mailparse && \
    apk del g++ autoconf make re2c
    
```

#### Others platforms
```
sudo apt install php-cli php-pear php-dev php-mbstring
pecl install mailparse
```

#### From source

AAAAMMDD should be `php-config --extension-dir`
```
git clone https://github.com/php/pecl-mail-mailparse.git
cd pecl-mail-mailparse
phpize
./configure
sed -i 's/#if\s!HAVE_MBSTRING/#ifndef MBFL_MBFILTER_H/' ./mailparse.c
make
sudo mv modules/mailparse.so /usr/lib/php/AAAAMMDD/
echo "extension=mailparse.so" | sudo tee /etc/php/7.1/mods-available/mailparse.ini
sudo phpenmod mailparse
```

#### Windows
You need to download mailparse DLL from http://pecl.php.net/package/mailparse and add the line "extension=php_mailparse.dll" to php.ini accordingly.

## How do I use it?

### Loading an email

You can load an email in 3 different ways – choose one:

```php
require_once __DIR__.'/vendor/autoload.php';

// 1. Specify a file path (string)
$parser = PhpMimeMailParser\Parser::fromPath('path/to/email.eml'); 

// 2. Specify the raw mime mail text (string)
$parser = PhpMimeMailParser\Parser::fromText('... raw email ...');

// 3. Specify a stream to work with mail server (stream)
$parser = PhpMimeMailParser\Parser::fromStream(fopen("php://stdin", "r"));
```

### Get the headers of the message

Get the sender and the receiver:

```php
$rawHeaderTo = $parser->getHeader('to');
// return "test" <test@example.com>, "test2" <test2@example.com>

$arrayHeaderTo = $parser->getAddresses('to');
// return [["display"=>"test", "address"=>"test@example.com", false]]

$rawHeaderFrom = $parser->getHeader('from');
// return "test" <test@example.com>

$arrayHeaderFrom = $parser->getAddresses('from');
// return [["display"=>"test", "address"=>"test@example.com", "is_group"=>false]]
```

Get the subject:

```php
$subject = $parser->getSubject();
```

Get other headers:

```php
$rawHeaders = $parser->getHeadersRaw();
// return all headers as an array, no charset conversion

$headers = $parser->getHeaders();
// return all headers as an array, with charset conversion
```

### Get the body of the message

```php
$text = $parser->getText();
// return the text version

$html = $parser->getHtml();
// return the html version with embedded contents like inline images

$html2 = $parser->getHtmlNotEmbedded();
// return the html version without embedded contents

```

### Get attachments

Save all attachments in a directory

```php
$parser->saveNestedAttachments('/path/to/save/attachments/', ['attachment', 'inline']);
// return all attachments saved in the directory (include inline attachments)

$parser->saveNestedAttachments('/path/to/save/attachments/', ['attachment']);
// return all attachments saved in the directory (exclude inline attachments)

// by default, the duplicates attachments are saved like this: logo.jpg, logo_1.jpg, ..., logo_100.jpg, YY34UFHBJ.jpg
// you can also change the strategy to handle duplicates filenames

$parserConfig = new ParserConfig();
$parserConfig->setFilenameStrategy(Parser::ATTACHMENT_RANDOM_FILENAME);
$parser = Parser::fromPath('path/to/email.eml', $parserConfig);
$parser->saveNestedAttachments('/path/to/save/attachments/', ['attachment', 'inline']);
// return all attachments saved in the directory: YY34UFHBJ.jpg and F98DBZ9FZF.jpg

$parserConfig = new ParserConfig();
$parserConfig->setFilenameStrategy(Parser::ATTACHMENT_DUPLICATE_THROW);
$parser = Parser::fromPath('path/to/email.eml', $parserConfig);
$parser->saveNestedAttachments('/path/to/save/attachments/', ['attachment', 'inline']);
// return an exception when there is attachments duplicate.

```

Get all attachments

```php
$attachments = $parser->getAttachments();
// return an array of all attachments (include inline attachments)

$attachments = $parser->getAttachments(false);
// return an array of all attachments (exclude inline attachments)
```


Loop through all the Attachments
```php
foreach ($attachments as $attachment) {
    echo 'Filename : '.$attachment->getFilename().'<br />';
    // return logo.jpg
    
    echo 'Filesize : '.filesize($attach_dir.$attachment->getFilename()).'<br />';
    // return 1000
    
    echo 'Filetype : '.$attachment->getContentType().'<br />';
    // return image/jpeg
    
    echo 'MIME part string : '.$attachment->getMimePartStr().'<br />';
    // return the whole MIME part of the attachment

    $attachment->save('/path/to/save/myattachment/', Parser::ATTACHMENT_DUPLICATE_SUFFIX);
    // return the path and the filename saved (same strategy available than saveAttachments)
}
```

## Postfix configuration to manage email from a mail server

Next you need to forward emails to this script above. For that I'm using [Postfix](http://www.postfix.org/) like a mail server, you need to configure /etc/postfix/master.cf

Add this line at the end of the file (specify myhook to send all emails to the script test.php)
```
myhook unix - n n - - pipe
  				flags=F user=www-data argv=php -c /etc/php5/apache2/php.ini -f /var/www/test.php ${sender} ${size} ${recipient}
```

Edit this line (register myhook)
```
smtp      inet  n       -       -       -       -       smtpd
        			-o content_filter=myhook:dummy
```

The php script must use the fourth method to work with this configuration.

And finally the easiest way is to use my SaaS https://mailcare.io



## My sponsors

Thanks to [Bertel Torp](https://github.com/berteltorp) who is my first sponsor.


## Can I contribute?

Feel free to contribute!

	git clone https://github.com/php-mime-mail-parser/php-mime-mail-parser
	cd php-mime-mail-parser
	composer install
	./vendor/bin/phpunit

If you report an issue, please provide the raw email that triggered it. This helps us reproduce the issue and fix it more quickly.

## License

The php-mime-mail-parser/php-mime-mail-parser is open-sourced software licensed under the [MIT license](http://opensource.org/licenses/MIT)

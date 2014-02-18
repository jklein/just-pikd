<?php
/**
 * hhvm-wrapper
 *
 * Copyright (c) 2012-2013, Sebastian Bergmann <sebastian@phpunit.de>.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 *   * Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *
 *   * Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in
 *     the documentation and/or other materials provided with the
 *     distribution.
 *
 *   * Neither the name of Sebastian Bergmann nor the names of his
 *     contributors may be used to endorse or promote products derived
 *     from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
 * ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *
 * @package   hhvm-wrapper
 * @author    Sebastian Bergmann <sebastian@phpunit.de>
 * @copyright 2012-2013 Sebastian Bergmann <sebastian@phpunit.de>
 * @license   http://www.opensource.org/licenses/BSD-3-Clause  The BSD 3-Clause License
 * @since     File available since Release 2.0.0
 */

namespace SebastianBergmann\HHVM\Log;

use SebastianBergmann\HHVM\Result;

/**
 * Writes violations in Checkstyle XML format to a file.
 *
 * @author    Sebastian Bergmann <sebastian@phpunit.de>
 * @copyright 2012-2013 Sebastian Bergmann <sebastian@phpunit.de>
 * @license   http://www.opensource.org/licenses/BSD-3-Clause  The BSD 3-Clause License
 * @link      http://github.com/sebastianbergmann/hhvm-wrapper/tree
 * @since     Class available since Release 2.0.0
 */
class Checkstyle
{
    /**
     * @param Result $result
     * @param string $filename
     */
    public function generate(Result $result, $filename)
    {
        $out = new \XMLWriter;
        $out->openURI($filename);
        $out->setIndent(TRUE);
        $out->startDocument('1.0', 'UTF-8');
        $out->startElement('checkstyle');

        foreach ($result->getViolations() as $file => $lines) {
            $out->startElement('file');
            $out->writeAttribute('name', $file);

            foreach ($lines as $line => $violations) {
                foreach ($violations as $violation) {
                    $out->startElement('error');

                    $out->writeAttribute('line', $line);
                    $out->writeAttribute('message', $violation['message']);
                    $out->writeAttribute('severity', 'error');
                    $out->writeAttribute(
                      'source',
                      'HipHop.PHP.Analysis.' . $violation['source']
                    );

                    $out->endElement();
                }
            }

            $out->endElement();
        }

        $out->endElement();
        $out->flush();
    }
}

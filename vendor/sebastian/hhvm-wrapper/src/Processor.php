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

namespace SebastianBergmann\HHVM;

/**
 * Abstract wrapper for HHVM.
 *
 * @author    Sebastian Bergmann <sebastian@phpunit.de>
 * @copyright 2012-2013 Sebastian Bergmann <sebastian@phpunit.de>
 * @license   http://www.opensource.org/licenses/BSD-3-Clause  The BSD 3-Clause License
 * @link      http://github.com/sebastianbergmann/hhvm-wrapper/tree
 * @since     Class available since Release 2.0.0
 */
abstract class Processor
{
    /**
     * @var string
     */
    private $binary = 'hhvm';

    /**
     */
    public function __construct()
    {
        if (isset($_ENV['HPHP_HOME']) &&
            is_executable($_ENV['HPHP_HOME'] . '/hphp/hhvm/hhvm')) {
            $this->binary = $_ENV['HPHP_HOME'] . '/hphp/hhvm/hhvm';
        }
    }

    /**
     * @param  array  $files
     * @param  string $command
     * @param  string $outputFile
     * @return string
     */
    protected function process(array $files, $command, $outputFile)
    {
        $inputListFile = tempnam('/tmp', 'hhvm');
        $outputDir     = dirname($inputListFile) . DIRECTORY_SEPARATOR;

        file_put_contents($inputListFile, join("\n", $files));

        shell_exec(
          sprintf(
            '%s %s --input-list %s --output-dir %s --log 2 2>&1',
            $this->binary,
            $command,
            $inputListFile,
            $outputDir
          )
        );

        if (!file_exists($outputDir . $outputFile)) {
            throw new \RuntimeException(
              'HHVM failed to process the files.'
            );
        }

        unlink($inputListFile);

        $codeError = $outputDir . 'CodeError.js';
        $stats     = $outputDir . 'Stats.js';
        $program   = $outputDir . 'program';

        if ($outputFile != 'CodeError.js' && file_exists($codeError)) {
            unlink($codeError);
        }

        if (file_exists($program)) {
            unlink($program);
        }

        if (file_exists($stats)) {
            unlink($stats);
        }

        return $outputDir . $outputFile;
    }
}

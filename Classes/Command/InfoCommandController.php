<?php
/**
 * Created by PhpStorm.
 * User: daniel
 * Date: 11/04/2017
 * Time: 21:20
 */

namespace Cundd\Fleet\Command;

use Cundd\Fleet\Info\ExtensionService;
use Cundd\Fleet\Info\SystemService;
use TYPO3\CMS\Core\Utility\ArrayUtility;
use TYPO3\CMS\Extbase\Mvc\Controller\CommandController;

class InfoCommandController extends CommandController
{
    /**
     * @var ExtensionService
     */
    private $extensionService;

    /**
     * @var SystemService
     */
    private $systemService;

    /**
     * @param ExtensionService $extensionService
     * @param SystemService    $systemService
     */
    public function __construct(ExtensionService $extensionService, SystemService $systemService)
    {
        $this->extensionService = $extensionService;
        $this->systemService = $systemService;
    }

    /**
     * Print information
     *
     * @param string $key Type of information to fetch
     * @return void
     */
    public function infoCommand($key = '')
    {
        $allInformation = $this->getAllInformation();

        if ($key) {
            $information = ArrayUtility::getValueByPath($allInformation, $key, '.');
        } else {
            $information = $allInformation;
        }

        $this->output(json_encode($information, JSON_PRETTY_PRINT));

        $this->sendAndExit();
    }

    /**
     * @return array
     */
    private function getAllInformation()
    {
        return [
            'system'   => $this->systemService->getInformation(),
            'packages' => [
                'active'   => $this->extensionService->getActivePackages(),
                'inactive' => $this->extensionService->getInactivePackages(),
                'all'      => $this->extensionService->getAllPackages(),
            ],
        ];
    }

}

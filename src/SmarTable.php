<?php

/**
 * @see Zend_Controller_Action_Helper_Abstract
 */
require_once 'Zend/Controller/Action/Helper/Abstract.php';

/**
 * @category  SmarTable
 * @package   SmarTable
 * @copyright Copyright (c) 2010 Daniel Berstein
 */
class SmarTable extends Zend_Controller_Action_Helper_Abstract
{
    /**
     * Overloading
     *
     * @param string $method Method name called
     * @param array  $args   Arguments of the call
     *
     * @return mixed
     *
     * @thows Zend_Controller_Action_Expection
     */
    public function __call($method, $args)
    {
        $method = strtolower($method);

        switch ($method) {
            case 'render':
                return call_user_func_array(
                    array(
                        $this,
                        '_renderTable',
                    ),
                    $args
                );
                break;
            default:
                require_once 'Zend/Controller/Action/Exception.php';
                throw new Zend_Controller_Action_Exception(
                    sprintf(
                        'Invalid method "%s" called on SmarTable',
                        $method
                    )
                );
                break;
        }
    }

    /**
     * Renders a sortable table
     *
     * @param Zend_Db_Table_Abstract $table      Table instance to render
     * @param int                    $limitRows  Rows per page
     * @param int                    $offsetRows Rows offset
     *
     * @return void
     */
    protected function _renderTable(
        Zend_Db_Table_Abstract $table, $limitRows = 15, $offsetRows = 0
    )
    {
        //
    }
}

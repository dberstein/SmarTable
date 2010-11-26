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
     * @return string
     *
     * @thows Zend_Controller_Action_Expection
     */
    public function __call($method, $args)
    {
        $method = strtolower($method);

        switch ($method) {
            case 'render':
                // break intentionally ommitted
            case 'table':
                $forward = '_renderTable';
                break;
            case 'query':
                $forward = '_renderExpression';
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

        return call_user_func_array(
            array(
                $this,
                $forward,
            ),
            $args
        );
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
        $db = $table->getAdapter();
        $expression = $db->select()->from(
            array(
                'table' => $table->info('name'),
            )
        )->limit(
            $limitRows,
            $offsetRows
        );

        return $this->_renderExpression(
            $db,
            $expression
        );
    }

    /**
     * Renders a sortable expression
     *
     * @param Zend_Db_Adapter_Abstract $db         Database instance
     * @param Zend_Db_Select           $expression Expression to render
     *
     * @return void
     */
    protected function _renderExpression(
        Zend_Db_Adapter_Abstract $db, Zend_Db_Select $expression
    )
    {
        $result = $db->fetchAll($expression);
        return $this->_render($result);
    }

    /**
     * Returns the HTML for $data
     *
     * @param array $data   Data to render
     * @param array $column Column names
     *
     * @return string
     */
    protected function _render(array $data, array $columns = array())
    {
        if (empty($columns) && count($data)) {
            $columns = array_keys($data[key($data)]);
        }

        $html = sprintf(
            '<table>%s%s%s</table>',
            $this->_element('theader', $columns, 'tr', 'th'),
            $this->_element('tbody', $data),
            $this->_element('tfooter', $data, 'tr', 'th')
        );

        return $html;
    }

    /**
     * Returns the HTML for $data encompassed in element $element
     *
     * @param string $element     Container HTML element name
     * @param array  $data        Data to render
     * @param string $rowElement  HTML element to contain each row
     * @param string $cellElement HTML element to contain each cell
     *
     * @return string
     */
    protected function _element(
        $element, array $data, $rowElement = 'tr', $cellElement = 'td'
    )
    {
        $html = '<' . $element . '>';
        foreach ($data as $row) {
            $html = sprintf(
                '<%s$1>%s$2</%s$1>',
                $rowElement,
                array_map(
                    create_function(
                        '$v',
                        'return sprintf(
                            "<' . $cellElement . '>%s</' . $cellElement . '>",
                            htmlentities($v)
                        );',
                        $row
                    )
                )
            );
        }
        $html .= '</' . $element . '>';

        return $html;
    }
}

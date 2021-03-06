/**
* QCondition is used to build WHERE for SOQL statements
* @author  Jean-Philippe Monette
* @since   2017-03-21
*/
public virtual class QCondition implements QICondition {

    public enum ComparisonOperator { EQUALS, NOT_EQUALS, LESS_THAN, LESS_OR_EQUAL, GREATER_THAN, GREATER_OR_EQUAL, IS_LIKE, IS_IN, NOT_IN, INCLUDES, EXCLUDES }

    protected ComparisonOperator operatorValue;

    protected String field {
        protected get { return String.escapeSingleQuotes(field); }
        protected set;
    }

    protected Object fieldValue {
        protected get { return formatFieldValue(fieldValue); }
        protected set { fieldValue = value; }
    }

    public QCondition(String field) {
        this.field = field;
    }

    private Object formatFieldValue(Object val) {
        if (val instanceof List<Object>) {
            List<String> values = new List<String>();
            for (Object value : (List<Object>) val) {
                if (value instanceof String) {
                    values.add('\'' + escapeSoqlValue((String) value) + '\'');
                } else {
                    values.add(String.valueOf(value));
                }
            }
            return String.join(values, ', ');
        }
        if (val instanceof String) {
            return '\'' + escapeSoqlValue((String) val) + '\'';
        } else if (val instanceof Date) {
            String dateString = String.valueOf(val);
            return dateString.substring(0, dateString.indexOf(' '));
        } else if (val instanceof QDateLiteral) {
            return ((QDateLiteral)val).buildLiteral();
        } else if (val instanceof Q) {
            return ((Q)val).build();
        } else {
            return val;
        }
    }

    private String escapeSoqlValue(String value) {
        return String.escapeSingleQuotes(value.replace('\\', '\\\\'));
    }

    public QCondition isEqualTo(Object value) {
        this.operatorValue = ComparisonOperator.EQUALS;
        this.fieldValue = value;
        return this;
    }

    public QCondition isNotEqualTo(Object value) {
        this.operatorValue = ComparisonOperator.NOT_EQUALS;
        this.fieldValue = value;
        return this;
    }

    public QCondition isLessThan(Object value) {
        this.operatorValue = ComparisonOperator.LESS_THAN;
        this.fieldValue = value;
        return this;
    }

    public QCondition isLessOrEquals(Object value) {
        this.operatorValue = ComparisonOperator.LESS_OR_EQUAL;
        this.fieldValue = value;
        return this;
    }

    public QCondition isGreaterThan(Object value) {
        this.operatorValue = ComparisonOperator.GREATER_THAN;
        this.fieldValue = value;
        return this;
    }

    public QCondition isGreaterOrEquals(Object value) {
        this.operatorValue = ComparisonOperator.GREATER_OR_EQUAL;
        this.fieldValue = value;
        return this;
    }

    public QCondition isLike(String value) {
        this.operatorValue = ComparisonOperator.IS_LIKE;
        this.fieldValue = value;
        return this;
    }

    public QCondition isIn(Object values) {
        this.operatorValue = ComparisonOperator.IS_IN;
        this.fieldValue = values;
        return this;
    }

    public QCondition isIn(Q subQuery) {
        this.operatorValue = ComparisonOperator.IS_IN;
        this.fieldValue = subQuery;
        return this;
    }

    public QCondition isNotIn(Object values) {
        this.operatorValue = ComparisonOperator.NOT_IN;
        this.fieldValue = values;
        return this;
    }

    public QCondition isNotIn(Q subQuery) {
        this.operatorValue = ComparisonOperator.NOT_IN;
        this.fieldValue = subQuery;
        return this;
    }

    public QCondition includes(Object values) {
        this.operatorValue = ComparisonOperator.INCLUDES;
        this.fieldValue = values;
        return this;
    }

    public QCondition excludes(Object values) {
        this.operatorValue = ComparisonOperator.EXCLUDES;
        this.fieldValue = values;
        return this;
    }

    public QCondition isNull() {
        this.operatorValue = ComparisonOperator.EQUALS;
        this.fieldValue = null;
        return this;
    }

    public QCondition isNotNull() {
        this.operatorValue = ComparisonOperator.NOT_EQUALS;
        this.fieldValue = null;
        return this;
    }

    public virtual String build() {
        switch on operatorValue {
            when  EQUALS {
                return field + ' = ' + fieldValue;
            }
            when  NOT_EQUALS {
                return field + ' != ' + fieldValue;
            }
            when  LESS_THAN {
                return field + ' < ' + fieldValue;
            }
            when  LESS_OR_EQUAL {
                return field + ' <= ' + fieldValue;
            }
            when  GREATER_THAN {
                return field + ' > ' + fieldValue;
            }
            when  GREATER_OR_EQUAL {
                return field + ' >= ' + fieldValue;
            }
            when  IS_LIKE {
                return field + ' LIKE ' + fieldValue;
            }
            when  IS_IN {
                if (fieldValue instanceof QBindVariable) {
                    return field + ' IN ' + fieldValue;
                }
                return field + ' IN (' + fieldValue + ')';
            }
            when  NOT_IN {
                if (fieldValue instanceof QBindVariable) {
                    return field + ' NOT IN ' + fieldValue;
                }
                return field + ' NOT IN (' + fieldValue + ')';
            }
            when  INCLUDES {
                if (fieldValue instanceof QBindVariable) {
                    return field + ' INCLUDES ' + fieldValue;
                }
                return field + ' INCLUDES (' + fieldValue + ')';
            }
            when  EXCLUDES {
                if (fieldValue instanceof QBindVariable) {
                    return field + ' EXCLUDES ' + fieldValue;
                }
                return field + ' EXCLUDES (' + fieldValue + ')';
            }
            when else {
                return '';
            }
        }        
    }

}
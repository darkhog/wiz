module wiz.ast.jump;

import wiz.lib;
import wiz.ast.lib;

class Jump : Statement
{
    private bool _far;
    private parse.Keyword _type;
    private Expression _destination;
    private JumpCondition _condition;

    private Block inlining;
    private bool expanded;

    this(parse.Keyword type, bool far, compile.Location location)
    {
        super(location);
        _type = type;
        _far = far;
    }

    this(parse.Keyword type, bool far, JumpCondition condition, compile.Location location)
    {
        this(type, far, location);
        _condition = condition;
    }

    this(parse.Keyword type, bool far, Expression destination, JumpCondition condition, compile.Location location)
    {
        this(type, far, condition, location);
        _destination = destination;
    }

    bool expand(compile.Program program)
    {
        if(expanded)
        {
            return false;
        }

        expanded = true;

        switch(type)
        {
            case parse.Keyword.Continue:
                _type = parse.Keyword.Goto;
                _destination = new Attribute(["$loop"], location);
                break;
            case parse.Keyword.While:
                _type = parse.Keyword.Goto;
                _destination = new Attribute(["$endloop"], location);
                _condition = new JumpCondition(true, _condition);
                break;
            case parse.Keyword.Until:
            case parse.Keyword.Break:
                _type = parse.Keyword.Goto;
                _destination = new Attribute(["$endloop"], location);
                break;
            default: assert(0);
        }

        return true;
    }

    bool expand(compile.Program program, Block block)
    {
        if(expanded)
        {
            return false;
        }

        expanded = true;
        inlining = block;

        return true;
    }

    mixin compile.BranchAcceptor!(_destination, _condition, inlining);
    mixin helper.Accessor!(_type, _far, _destination, _condition);
}

class JumpCondition : Node
{
    private bool _negated;
    private Attribute _attr;
    private parse.Branch _branch;

    this(bool negated, JumpCondition condition)
    {
        super(condition.location);
        this._negated = negated ? !condition._negated : condition.negated;
        this._attr = condition._attr;
        this._branch = condition._branch;
    }

    this(bool negated, Attribute attr, compile.Location location)
    {
        super(location);
        _negated = negated;
        _attr = attr;
    }

    this(bool negated, parse.Branch branch, compile.Location location)
    {
        super(location);
        _negated = negated;
        _branch = branch;
    }

    mixin compile.BranchAcceptor!(_attr);
    mixin helper.Accessor!(_negated, _attr, _branch);
}
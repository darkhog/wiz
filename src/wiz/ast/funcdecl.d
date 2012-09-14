module wiz.ast.funcdecl;

import wiz.lib;
import wiz.ast.lib;

class FuncDecl : Statement
{
    public bool inlined;

    parse.Keyword _type;
    private string _name;
    private Statement[] _statements;

    private Block block;

    this(parse.Keyword type, string name, Block block, compile.Location location)
    {
        super(location);
        _type = type;
        _name = name;
        this.block = block;
    }

    void expand()
    {
        // def name:
        _statements ~= new LabelDecl(name, location);
        //     block
        _statements ~= block;
        //     return
        switch(type)
        {
            case parse.Keyword.Func:
                _statements ~= new Jump(parse.Keyword.Return, false, location);
                break;
            case parse.Keyword.Task:
                _statements ~= new Jump(parse.Keyword.Resume, false, location);
                break;
            default:
                assert(0);
        }

        block = null;
    }

    mixin compile.BranchAcceptor!(block, _statements);
    mixin helper.Accessor!(_type, _name, _statements);
}
clonableView
============

在 Web 开发过程中，经常会碰到需要为某个 Widget 增加一个克隆的按钮，可以复制某个表格的字段，本类库可以帮助到您。

本类库提供了 Backbone 和 Javascript 两个版本，Javascript 版本是通过 Backbone 版本翻译过来，在使用方法上是非常类同的。

本类库仅提供了克隆渲染功能，表单的处理依然需要开发者自己实现。

本类库遵循 MIT 协议，随意修改使用，无需告知作者。

使用方法
-------

以 Javascript 版本为例，其中提供了 test.html 供测试使用，Backbone 版本的使用方法是完全一致的。

    var clonableView = new ClonableView({
        $html: $($('textarea[name="html"]').val()),
        allowBlank: $('input[name="allowBlank"]').prop('checked'),
        limit: $('select[name="limit"]').val()
    });
    clonableView.render().$el.appendTo($container);
    
Backbone 版说明
--------------

参数:
 
 * subviewClass [CLASS] - 需要克隆的子 View 的类
 * subviewOptions [OBJECT] - 子 View 参数
 * allowBlank [BOOLEAN] - 是否允许为空值
 * limit [INTEGER] - 克隆的数量限制

事件：
 
 * subviewPreAdd: 子 View 添加前的事件
 * subviewPostAdded: 子 View 添加后的事件
 * subviewPreRemoved: 子 View 删除前的事件
 * subviewPostRemoved:  子 View 删除后的事件

    
Javascript 版说明
----------------

参数：

 * $html: [jQuery OBJECT]: 需要克隆的 jQuery 对象
 * allowBlank [BOOLEAN] - 是否允许为空值
 * limit [INTEGER] - 克隆的数量限制
 * preAdd [FUNCTION]: 添加前回调
 * postAdded [FUNCTION]: 添加后回调
 * preRemove [FUNCTION]: 删除前回调
 * postRemoved [FUNCTION]: 删除后回调

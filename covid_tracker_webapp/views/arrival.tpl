% rebase('base.tpl', title='New Visit')
<div class="row">
	<div class="col-md-12">
<form action="/arrival" method="post">
	Visitor-ID: <input type="text" name="visitor_id"><br>
	<input type="submit" value="Submit">
</form>
<div class="row">
    <div class="col-md-12">
    <h3> {{message2}}</h3>
    </div>
</div>
	</div>
</div>
% rebase('base.tpl', title='Register')
<div class="row">
	<div class="col-md-12">
<form action="/register" method="post">
	First Name: <input type="text" name="fname"><br>
	Surname   : <input type="text" name="sname"><br>
	Email     : <input type="text" name="email"><br>
	<input type="submit" value="Submit">
</form>

<div class="row">
    <div class="col-md-12">
    % if message1 == None:
    <h3>Your name already exists</h3>
    
    % else:
    <h3> {{message1}}</h3>
    % end
    </div>
</div>
	</div>
</div>
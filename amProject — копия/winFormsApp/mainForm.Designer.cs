namespace winFormsApp
{
    partial class formMain
    {
        /// <summary>
        /// Обязательная переменная конструктора.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Освободить все используемые ресурсы.
        /// </summary>
        /// <param name="disposing">истинно, если управляемый ресурс должен быть удален; иначе ложно.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Код, автоматически созданный конструктором форм Windows

        /// <summary>
        /// Требуемый метод для поддержки конструктора — не изменяйте 
        /// содержимое этого метода с помощью редактора кода.
        /// </summary>
        private void InitializeComponent()
        {
            this.panelMSSQLCreds = new System.Windows.Forms.Panel();
            this.buttonUseConnection = new System.Windows.Forms.Button();
            this.buttonCheckDBConn = new System.Windows.Forms.Button();
            this.labelServerName = new System.Windows.Forms.Label();
            this.textBoxServerName = new System.Windows.Forms.TextBox();
            this.panelChoose = new System.Windows.Forms.Panel();
            this.buttonQuery1 = new System.Windows.Forms.Button();
            this.panel1 = new System.Windows.Forms.Panel();
            this.buttonExit = new System.Windows.Forms.Button();
            this.panelMSSQLCreds.SuspendLayout();
            this.panelChoose.SuspendLayout();
            this.panel1.SuspendLayout();
            this.SuspendLayout();
            // 
            // panelMSSQLCreds
            // 
            this.panelMSSQLCreds.Controls.Add(this.buttonUseConnection);
            this.panelMSSQLCreds.Controls.Add(this.buttonCheckDBConn);
            this.panelMSSQLCreds.Controls.Add(this.labelServerName);
            this.panelMSSQLCreds.Controls.Add(this.textBoxServerName);
            this.panelMSSQLCreds.Dock = System.Windows.Forms.DockStyle.Top;
            this.panelMSSQLCreds.Location = new System.Drawing.Point(0, 0);
            this.panelMSSQLCreds.Name = "panelMSSQLCreds";
            this.panelMSSQLCreds.Size = new System.Drawing.Size(1165, 66);
            this.panelMSSQLCreds.TabIndex = 0;
            // 
            // buttonUseConnection
            // 
            this.buttonUseConnection.Location = new System.Drawing.Point(649, 14);
            this.buttonUseConnection.Name = "buttonUseConnection";
            this.buttonUseConnection.Size = new System.Drawing.Size(251, 31);
            this.buttonUseConnection.TabIndex = 3;
            this.buttonUseConnection.Text = "Использовать подключение ...";
            this.buttonUseConnection.UseVisualStyleBackColor = true;
            // 
            // buttonCheckDBConn
            // 
            this.buttonCheckDBConn.Location = new System.Drawing.Point(392, 14);
            this.buttonCheckDBConn.Name = "buttonCheckDBConn";
            this.buttonCheckDBConn.Size = new System.Drawing.Size(251, 31);
            this.buttonCheckDBConn.TabIndex = 2;
            this.buttonCheckDBConn.Text = "Проверить соединение ...";
            this.buttonCheckDBConn.UseVisualStyleBackColor = true;
            this.buttonCheckDBConn.Click += new System.EventHandler(this.buttonCheckDBConn_Click);
            // 
            // labelServerName
            // 
            this.labelServerName.AutoSize = true;
            this.labelServerName.Location = new System.Drawing.Point(12, 21);
            this.labelServerName.Name = "labelServerName";
            this.labelServerName.Size = new System.Drawing.Size(91, 17);
            this.labelServerName.TabIndex = 1;
            this.labelServerName.Text = "ServerName:";
            // 
            // textBoxServerName
            // 
            this.textBoxServerName.Location = new System.Drawing.Point(109, 18);
            this.textBoxServerName.Name = "textBoxServerName";
            this.textBoxServerName.Size = new System.Drawing.Size(276, 22);
            this.textBoxServerName.TabIndex = 0;
            // 
            // panelChoose
            // 
            this.panelChoose.Controls.Add(this.buttonQuery1);
            this.panelChoose.Dock = System.Windows.Forms.DockStyle.Fill;
            this.panelChoose.Location = new System.Drawing.Point(0, 66);
            this.panelChoose.Name = "panelChoose";
            this.panelChoose.Size = new System.Drawing.Size(1165, 521);
            this.panelChoose.TabIndex = 1;
            // 
            // buttonQuery1
            // 
            this.buttonQuery1.Location = new System.Drawing.Point(15, 6);
            this.buttonQuery1.Name = "buttonQuery1";
            this.buttonQuery1.Size = new System.Drawing.Size(249, 39);
            this.buttonQuery1.TabIndex = 0;
            this.buttonQuery1.Text = "Запрос 1";
            this.buttonQuery1.UseVisualStyleBackColor = true;
            this.buttonQuery1.Click += new System.EventHandler(this.buttonQuery1_Click);
            // 
            // panel1
            // 
            this.panel1.Controls.Add(this.buttonExit);
            this.panel1.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.panel1.Location = new System.Drawing.Point(0, 550);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(1165, 37);
            this.panel1.TabIndex = 2;
            // 
            // buttonExit
            // 
            this.buttonExit.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.buttonExit.Location = new System.Drawing.Point(981, 3);
            this.buttonExit.Name = "buttonExit";
            this.buttonExit.Size = new System.Drawing.Size(183, 31);
            this.buttonExit.TabIndex = 0;
            this.buttonExit.Text = "Выход";
            this.buttonExit.UseVisualStyleBackColor = true;
            this.buttonExit.Click += new System.EventHandler(this.buttonExit_Click);
            // 
            // formMain
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1165, 587);
            this.Controls.Add(this.panel1);
            this.Controls.Add(this.panelChoose);
            this.Controls.Add(this.panelMSSQLCreds);
            this.Name = "formMain";
            this.Text = "MSSQL Server mngmnt views";
            this.panelMSSQLCreds.ResumeLayout(false);
            this.panelMSSQLCreds.PerformLayout();
            this.panelChoose.ResumeLayout(false);
            this.panel1.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Panel panelMSSQLCreds;
        private System.Windows.Forms.Panel panelChoose;
        private System.Windows.Forms.Panel panel1;
        private System.Windows.Forms.Button buttonExit;
        private System.Windows.Forms.Label labelServerName;
        private System.Windows.Forms.TextBox textBoxServerName;
        private System.Windows.Forms.Button buttonUseConnection;
        private System.Windows.Forms.Button buttonCheckDBConn;
        private System.Windows.Forms.Button buttonQuery1;
    }
}


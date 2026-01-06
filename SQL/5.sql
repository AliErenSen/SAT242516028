use SAT242516028

INSERT [dbo].[AspNetRoles] ([Id], [Name], [NormalizedName], [ConcurrencyStamp]) VALUES (N'6508F244-D53E-4288-9ABA-45AA176C71EA', N'User', N'USER', NULL)
GO
INSERT [dbo].[AspNetRoles] ([Id], [Name], [NormalizedName], [ConcurrencyStamp]) VALUES (N'6B1B9E5D-11C6-4E77-8835-0117B19FDA6B', N'Admin', N'ADMIN', NULL)
GO
INSERT [dbo].[AspNetUsers] ([Id], [UserName], [NormalizedUserName], [Email], [NormalizedEmail], [EmailConfirmed], [PasswordHash], [SecurityStamp], [ConcurrencyStamp], [PhoneNumber], [PhoneNumberConfirmed], [TwoFactorEnabled], [LockoutEnd], [LockoutEnabled], [AccessFailedCount]) VALUES (N'5a2da1bf-b499-4478-87a5-70354d17257b', N'a@a.com', N'A@A.COM', N'a@a.com', N'A@A.COM', 0, N'AQAAAAIAAYagAAAAEJLEIVS0m+8s/vQyrwH6byFhZP7msut1Y2Eb+QNfsA6DjF68sCDkieINBkLPNBkSDw==', N'43XLU63TFP3PAE34DBSUV7RNY5D5UIAF', N'9122e788-757b-4ebf-9066-529be7dd2669', NULL, 0, 0, NULL, 1, 0)
GO
INSERT [dbo].[AspNetUsers] ([Id], [UserName], [NormalizedUserName], [Email], [NormalizedEmail], [EmailConfirmed], [PasswordHash], [SecurityStamp], [ConcurrencyStamp], [PhoneNumber], [PhoneNumberConfirmed], [TwoFactorEnabled], [LockoutEnd], [LockoutEnabled], [AccessFailedCount]) VALUES (N'caebe4ee-253f-4b73-b488-a91098742fb7', N'u@u.com', N'U@U.COM', N'u@u.com', N'U@U.COM', 0, N'AQAAAAIAAYagAAAAEE9aONMiSHkzgZCPk+aU5z1WuvDHQyjTWcZxa0Ql5RFJMQhOvKKYZ29fC2JfPy+ooQ==', N'2KWZWFO237BDKNC4V3J7PPZMHK2TQFPH', N'0a99eb01-7df3-4889-be33-d900262f9d16', NULL, 0, 0, NULL, 1, 0)
GO
INSERT [dbo].[AspNetUserRoles] ([UserId], [RoleId]) VALUES (N'caebe4ee-253f-4b73-b488-a91098742fb7', N'6508F244-D53E-4288-9ABA-45AA176C71EA')
GO
INSERT [dbo].[AspNetUserRoles] ([UserId], [RoleId]) VALUES (N'5a2da1bf-b499-4478-87a5-70354d17257b', N'6B1B9E5D-11C6-4E77-8835-0117B19FDA6B')
GO 